
function Assert-ForeignKey
{
    <#
    .SYNOPSIS
    Tests that a foreign key exists and the columns that are a part of it.
    #>
    param(
        [Parameter(Mandatory=$true,ParameterSetName='ByDefaultName')]
        [string]
        # The name of the table whose foreign key to get.
        $TableName,

        [Parameter(ParameterSetName='ByDefaultName')]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,ParameterSetName='ByDefaultName')]
        [string]
        # The table that the foreign key references
        $References,

        [Parameter(ParameterSetName='ByDefaultName')]
        [string]
        # The schema name of the reference table.  Defaults to `dbo`.
        $ReferencesSchema = 'dbo',

        [Parameter(Mandatory=$true,ParameterSetName='ByExplicitName')]
        [string]
        # The name of the foreign key.
        $Name,

        [Parameter()]
        [string]
        # Test OnDelete
        $OnDelete,

        [Parameter()]
        [string]
        # Test OnUpdate
        $OnUpdate,

        [Parameter()]
        [switch]
        # Test Not For Replication
        $NotForReplication,

        [Parameter()]
        [switch]
        # Test Disabled
        $IsDisabled
    )

    Set-StrictMode -Version Latest

    if( $PSCmdlet.ParameterSetName -eq 'ByDefaultName' )
    {
        $fk = Get-ForeignKey -SchemaName $SchemaName -TableName $TableName -ReferencesSchema $ReferencesSchema -References $References
    }
    else
    {
        $fk = Get-ForeignKey -Name $Name
    }

    #Test for non-null objects
    $fk | Should -Not -BeNullOrEmpty -Because ('foreign Key on table {0}.{1} doesn''t exist.' -f $SchemaName,$TableName)

    foreach ($_ in $fk.Columns)
    {
        $_.constraint_object_id | Should -Be $fk.object_id
        $_.parent_object_id | Should -Be $fk.parent_object_id
        $_.referenced_object_id | Should -Be $fk.referenced_object_id
    }

    if ($OnDelete)
    {
        $fk.delete_referential_action_desc | Should -Be $OnDelete
    }
    else
    {
        $fk.delete_referential_action_desc | Should -Be "NO_ACTION"
    }

    if ($OnUpdate)
    {
        $fk.update_referential_action_desc | Should -Be $OnUpdate
    }
    else
    {
        $fk.update_referential_action_desc | Should -Be "NO_ACTION"
    }

    if ($NotForReplication)
    {
        $fk.is_not_for_replication | Should -BeTrue
    }
    else
    {
        $fk.is_not_for_replication | Should -BeFalse
    }

    if ($IsDisabled)
    {
        $fk.is_disabled | Should -BeTrue
    }
    else
    {
        $fk.is_disabled | Should -BeFalse
    }
}
