
function Add-UniqueConstraint
{
    <#
    .SYNOPSIS
    Creates a UNIQUE constraint on the specified column and table.

    .DESCRIPTION
    Creates a UNIQUE constraint on the specified column and table.  
    You can use UNIQUE constraints to make sure that no duplicate values are entered in specific columns that do not participate in a primary key. Although both a UNIQUE constraint and a PRIMARY KEY constraint enforce uniqueness, use a UNIQUE constraint instead of a PRIMARY KEY constraint when you want to enforce the uniqueness of a column, or combination of columns, that is not the primary key.

    .LINK
    Add-Unique Constraint

    .EXAMPLE
    Add-UniqueConstraint -TableName Cars -ColumnName Year

    Adds an unique constraint on column 'Year' in the table 'Cars'

    .EXAMPLE 
    Add-UniqueConstraint -TableName 'Cars' -ColumnName 'Year' -Option @('IGNORE_DUP_KEY = ON','ALLOW_ROW_LOCKS = OFF')

    Adds an unique constraint on column 'Year' in the table 'Cars' with specified options

    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the target table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the target table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string[]]
        # The column(s) on which the index is based
        $ColumnName,

        [Switch]
        # Creates a clustered index, otherwise non-clustered
        $Clustered,

        [Int]
        # FillFactor as Integer
        $FillFactor,

        [string[]]
        # An array of index options.
        $Option,

        [string]
        # The value of the `ON` clause, which controls the filegroup/partition to use for the index.
        $On
        
    )

    Set-StrictMode -Version Latest

    ## Read Flags, Set Strings

    $ClusteredClause = ''
    if ($Clustered)
    {
        $ClusteredClause = "clustered"
    }

    $FillFactorClause = ''
    $OptionClause = ''
    if ($Option -or $FillFactor)
    {
        if ($FillFactor)
        {
            $FillFactorClause = "fillfactor=" + $FillFactor.ToString()
            $Option = $Option + $FillFactorClause
        }
        $OptionClause = $Option -join ','
        $OptionClause = "with ({0})" -f $OptionClause
    }
  
    $OnClause = ''
    if ($On)
    {
        $OnClause = "on {0}" -f $On
    }

    ## Construct Index name

    $constraintname = New-ConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName -Unique

    ## Construct Comma Separated List of Columns

    $ColumnClause = $ColumnName -join ','

$query = @'
    alter table {0}.{1}
        add constraint {2} unique {3}({4})
        {5}{6}

'@ -f $SchemaName, $TableName, $constraintname, $ClusteredClause, $ColumnClause, $OptionClause, $OnClause
    
    Write-Host (' {0}.{1} +{2} ({3})' -f $SchemaName,$TableName,$constraintname,$ColumnClause)

    $op = New-Object 'Rivet.Operations.RawQueryOperation' $query
    Invoke-MigrationOperation -Operation $op
}
