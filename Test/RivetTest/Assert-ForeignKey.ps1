
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
        [string[]]
        # The column(s) that are part of the foreign key.
        $ColumnName,

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
        # Test for removal
        $TestRemoval

    )
    
    Set-StrictMode -Version Latest

    $fk = Get-ForeignKey
    $fkc = Get-ForeignKeyColumns

    if ($TestRemoval)
    {
         #Test for null objects
        Assert-Null $fk ('foreign Key on table {0}.{1} still exists.' -f $SchemaName,$TableName)
        Assert-Null $fkc ('foreign Key on table {0}.{1} still exists.' -f $SchemaName,$TableName)
    }
    else
    {
        #Test for non-null objects
        Assert-NotNull $fk ('foreign Key on table {0}.{1} doesn''t exist.' -f $SchemaName,$TableName)
        Assert-NotNull $fkc ('foreign Key on table {0}.{1} doesn''t exist.' -f $SchemaName,$TableName)

        $name = New-ConstraintName -TableName $TableName -SchemaName $SchemaName -ColumnName $ColumnName -ForeignKey
    
        #Test for equal Constraint Name
        Assert-Equal $name $fk.name

        foreach ($_ in $fkc)
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
    }
    
}