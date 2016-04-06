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
    
    .EXAMPLE
    Add-ForeignKey -TableName Cars -ColumnName DealerID -References Dealer -ReferencedColumn DealerID -NoCheck

    Adds a foreign key to the 'Cars' table on the 'DealerID' column that references the 'DealerID' column on the 'Dealer' table without validating the current contents of the table against this key.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the table to alter.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1)]
        [string[]]
        # The column(s) that should be part of the foreign key.
        $ColumnName,

        [Parameter(Mandatory=$true,Position=2)]
        [string]
        # The table that the foreign key references
        $References,

        [Parameter()]
        [string]
        # The schema name of the reference table.  Defaults to `dbo`.
        $ReferencesSchema = 'dbo',

        [Parameter(Mandatory=$true,Position=3)]
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
        $NotForReplication,

        [Parameter()]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name,

        [Switch]
        # Specifies that the data in the table is not validated against a newly added FOREIGN KEY constraint. If not specified, WITH CHECK is assumed for new constraints.
        $NoCheck
    )

    Set-StrictMode -Version Latest
    
    $source_columns = $ColumnName -join ','
    $ref_columns = $ReferencedColumn -join ','
    
    if ($PSBoundParameters.containskey("Name"))
    {
        New-Object 'Rivet.Operations.AddForeignKeyOperation' $SchemaName, $TableName, $ColumnName, $ReferencesSchema, $references, $ReferencedColumn, $Name, $OnDelete, $OnUpdate, $NotForReplication, $NoCheck
    }
    else
    {
        New-Object 'Rivet.Operations.AddForeignKeyOperation' $SchemaName, $TableName, $ColumnName, $ReferencesSchema, $references, $ReferencedColumn, $OnDelete, $OnUpdate, $NotForReplication, $NoCheck
    }
}

    