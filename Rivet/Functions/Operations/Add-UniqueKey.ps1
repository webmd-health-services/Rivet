function Add-UniqueKey
{
    <#
    .SYNOPSIS
    Creates a UNIQUE constraint on the specified column and table.

    .DESCRIPTION
    Creates a UNIQUE constraint on the specified column and table.  
    You can use UNIQUE constraints to make sure that no duplicate values are entered in specific columns that do not participate in a primary key. Although both a UNIQUE constraint and a PRIMARY KEY constraint enforce uniqueness, use a UNIQUE constraint instead of a PRIMARY KEY constraint when you want to enforce the uniqueness of a column, or combination of columns, that is not the primary key.

    .EXAMPLE
    Add-UniqueKey -TableName Cars -ColumnName Year

    Adds an unique constraint on column 'Year' in the table 'Cars'

    .EXAMPLE 
    Add-UniqueKey -TableName 'Cars' -ColumnName 'Year' -Option @('IGNORE_DUP_KEY = ON','ALLOW_ROW_LOCKS = OFF')

    Adds an unique constraint on column 'Year' in the table 'Cars' with specified options
    #>
    [CmdletBinding()]
    param(
        # The schema name of the target table.  Defaults to `dbo`.
        [String]$SchemaName = 'dbo',

        [Parameter(Mandatory,Position=0)]
        # The name of the target table.
        [String]$TableName,

        # The name for the <object type>. If not given, a sensible name will be created.
        [String]$Name,

        [Parameter(Mandatory,Position=1)]
        # The column(s) on which the index is based
        [String[]]$ColumnName,

        # Creates a clustered index, otherwise non-clustered
        [switch]$Clustered,

        # FillFactor as Integer
        [int]$FillFactor,

        # An array of index options.
        [String[]]$Option,

        # The value of the `ON` clause, which controls the filegroup/partition to use for the index.
        [String]$On
    )

    Set-StrictMode -Version Latest

    if( -not $Name )
    {
        $Name = New-ConstraintName -UniqueKey -SchemaName $SchemaName -TableName $TableName -ColumnName $ColumnName
        Write-Warning ("Unique key constraint names will be required in a future version of Rivet. Please add a ""Name"" parameter (with a value of ""$($Name)"") to the Add-UniqueKey operation on the [$($SchemaName)].[$($TableName)] table's [$($ColumnName -join '], [')] columns.")
    }

    [Rivet.Operations.AddUniqueKeyOperation]::new($SchemaName, $TableName, $Name, $ColumnName, $Clustered, $FillFactor, $Option, $On)
}
