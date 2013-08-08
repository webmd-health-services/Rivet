
function Add-ForeignKey
{
    <#
    .SYNOPSIS
    Adds a foreign key to an existing table that doesn't have a foreign key constraint.

    .DESCRIPTION
    Adds a foreign key to a table.  The table/column that the foreign key references must have a primary key.  If the table already has a foreign key, make sure to remove it with `Remove-ForeignKey`.

    .LINK
    Add-ForeignKey

    .EXAMPLE
    Add-ForeignKey -TableName Cars -ColumnName DealerID -References Dealer -ReferencedColumn DealerID

    Adds a foreign key to the 'Cars' table on the 'DealerID' column that references the 'DealerID' column on the 'Dealer' table.

    .EXAMPLE
    Add-ForeignKey -TableName 'Cars' -ColumnName 'DealerID' -References 'Dealer' -ReferencedColumn 'DealerID' -OnDelete 'CASCADE' -OnUpdate 'CASCADE' -NotForReplication

    Adds a foreign key to the 'Cars' table on the 'DealerID' column that references the 'DealerID' column on the 'Dealer' table with the options to cascade on delete and update, and also set notforreplication
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table to alter.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string[]]
        # The column(s) that should be part of the foreign key.
        $ColumnName,

        [Parameter(Mandatory=$true)]
        [string]
        # The table that the foreign key references
        $References,

        [Parameter()]
        [string]
        # The schema name of the reference table.  Defaults to `dbo`.
        $ReferencesSchema = 'dbo',

        [Parameter(Mandatory=$true)]
        [string[]]
        # The column(s) that the foreign key references
        $ReferencedColumn,

        [Parameter()]
        [string]
        # Specifies what action happens to rows in the table that is altered, if those rows have a referential relationship and the referenced row is deleted from the parent table. The default is NO ACTION.
        $OnDelete,

        [Parameter()]
        [string]
        # Specifies what action happens to rows in the table altered when those rows have a referential relationship and the referenced row is updated in the parent table. The default is NO ACTION.
        $OnUpdate,

        [Parameter()]
        [switch]
        # Can be specified for FOREIGN KEY constraints and CHECK constraints. If this clause is specified for a constraint, the constraint is not enforced when replication agents perform insert, update, or delete operations.
        $NotForReplication


    )

    Set-StrictMode -Version Latest

    $name = New-ForeignKeyConstraintName -SourceSchema $SchemaName -SourceTable $TableName -TargetSchema $ReferencesSchema -TargetTable $References
    
    $source_columns = $ColumnName -join ','
    $ref_columns = $ReferencedColumn -join ','

    $OnDeleteClause = ''
    if ($OnDelete)
    {
        $OnDeleteClause = "on delete {0}" -f $OnDelete
    }

    $OnUpdateClause = ''
    if ($OnUpdate)
    {
        $OnUpdateClause = "on update {0}" -f $OnUpdate
    }

    $NotForReplicationClause = ''
    if ($NotForReplication)
    {
        $NotForReplicationClause = "not for replication"
    }

    $query = @'
    alter table [{0}].[{1}] add constraint {2} foreign key ({3}) references {4}.{5}({6}) {7} {8} {9}
'@ -f $SchemaName,$TableName,$name,$source_columns,$ReferencesSchema,$References,$ref_columns, $OnDeleteClause, $OnUpdateClause, $NotForReplicationClause

    Write-Host (' {0}.{1} +{2} ({3}) => {4}.{5} ({6})' -f $SchemaName,$TableName,$name,$source_columns,$ReferencesSchema,$References,$ref_columns)
    Invoke-Query -Query $query
}
