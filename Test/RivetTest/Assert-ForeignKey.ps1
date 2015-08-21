
function Assert-ForeignKey
{
    <#
    .SYNOPSIS
    Tests that a foreign key exists and the columns that are a part of it.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table whose foreign key to get.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The table that the foreign key references
        $References,

        [Parameter()]
        [string]
        # The schema name of the reference table.  Defaults to `dbo`.
        $ReferencesSchema = 'dbo',

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

    $fk = Get-ForeignKey -SchemaName $SchemaName -TableName $TableName -ReferencesSchema $ReferencesSchema -References $References

    #Test for non-null objects
    Assert-NotNull $fk ('foreign Key on table {0}.{1} doesn''t exist.' -f $SchemaName,$TableName)

    foreach ($_ in $fk.Columns)
    {
        Assert-Equal $fk.object_id $_.constraint_object_id
        Assert-Equal $fk.parent_object_id $_.parent_object_id
        Assert-Equal $fk.referenced_object_id $_.referenced_object_id
    }

    if ($OnDelete)
    {
        Assert-Equal $OnDelete $fk.delete_referential_action_desc 
    }
    else
    {
        Assert-Equal "NO_ACTION" $fk.delete_referential_action_desc 
    }

    if ($OnUpdate)
    {
        Assert-Equal $OnUpdate $fk.update_referential_action_desc 
    }
    else
    {
        Assert-Equal "NO_ACTION" $fk.update_referential_action_desc 
    }

    if ($NotForReplication)
    {
        Assert-Equal "True" $fk.is_not_for_replication
    }
    else
    {
        Assert-Equal "False" $fk.is_not_for_replication
    }

    if ($IsDisabled) 
    {
        Assert-True $fk.is_disabled
    }
    else
    {
        Assert-False $fk.is_disabled
    }
    
}
