function New-Column
{
    <#
    .SYNOPSIS
    Creates a column object of an explicit datatype which can be used with the `Add-Table` or `Add-Column` migrations.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Members' {
            New-Column 'Birthday' 'datetime' 
        }
    
    This column is useful for creating columns of custom types or types for which Rivet doesn't have a specific function.

    Returns an object that can be used when adding columns or creating tables to get the SQL needed to create that column. 
    
    .LINK
    New-BigIntColumn

    .LINK
    New-BinaryColumn

    .LINK
    New-BitColumn

    .LINK
    New-CharColumn

    .LINK
    New-DateColumn

    .LINK
    New-DateTime2Column

    .LINK
    New-DateTimeOffsetColumn

    .LINK
    New-DecimalColumn

    .LINK
    New-FloatColumn

    .LINK
    New-HierarchyIDColumn

    .LINK
    New-IntColumn

    .LINK
    New-MoneyColumn

    .LINK
    New-NCharColumn

    .LINK
    New-NVarCharColumn

    .LINK
    New-RealColumn

    .LINK
    New-RowVersionColumn

    .LINK
    New-SmallDateTimeColumn

    .LINK
    New-SmallIntColumn

    .LINK
    New-SmallMoneyColumn

    .LINK
    New-SqlVariantColumn

    .LINK
    New-TimeColumn

    .LINK
    New-TinyIntColumn

    .LINK
    New-UniqueIdentifierColumn

    .LINK
    New-VarBinaryColumn

    .LINK
    New-VarCharColumn

    .LINK
    New-XmlColumn

    .EXAMPLE
    Add-Table 'Members' { New-Column 'Birthday' 'datetime' -NotNull }

    Demonstrates how to create a required `datetime` column.

    .EXAMPLE
    Add-Table 'Members' { New-Column 'Birthday' 'float(7)' -NotNull }

    Demonstrates that the value of the `DataType` parameter should also include any precision/scale/size specifiers.

    .EXAMPLE
    Add-Table 'Members' { New-Column 'Birthday' 'datetime' -Sparse }

    Demonstrate show to create a nullable, sparse `datetime` column when adding a new table.

    .EXAMPLE
    Add-Table 'Members' { New-Column 'Birthday' 'datetime' -NotNull -Default 'getdate()' }
    
    Demonstrates how to create a date column with a default value, in this case the current date.  (You alwyas use UTC dates, right?)  Probably not a great example, setting someone's birthday to the current date. Reasons are left as an exercise for the reader.

    .EXAMPLE
    Add-Table 'Members' { New-Column 'Birthday' 'datetime' -Description 'The members birthday.' }

    Demonstrates how to create an optional date column with a description.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(

        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The Name of the new column.
        $Name,

        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The datatype of the new column, including precision/scale/size specifiers.
        $DataType,

        [Parameter(ParameterSetName='Nullable')]
        [Switch]
        # Optimizes the column storage for null values. Cannot be used with the `NotNull` switch.
        $Sparse,

        [Parameter(ParameterSetName='NotNull')]
        [Switch]
        # Makes the column not nullable.  Canno be used with the `Sparse` switch.
        $NotNull,

        [Object]
        # A SQL Server expression for the column's default value.
        $Default,

        [string]
        # A description of the column.
        $Description        
    )

    $nullable = 'Null'
    if( $PSCmdlet.ParameterSetName -eq 'NotNull' )
    {
        $nullable = 'NotNull'
    }
    elseif( $Sparse )
    {
        $nullable = 'Sparse'
    }

    New-Object Rivet.Column $Name,$DataType,$nullable,$Default,$Description
}