function New-SmallMoneyColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an SmallMoney datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Items' {
            SmallMoney 'Price'
        }

    ## ALIASES

     * SmallMoney

    .EXAMPLE
    Add-Table 'Items' { SmallMoney 'Price' }

    Demonstrates how to create an optional `smallmoney` column called `Price`.

    .EXAMPLE
    Add-Table 'Items' { SmallMoney 'Price' -NotNull }

    Demonstrates how to create a required `smallmoney` column called `Price`.

    .EXAMPLE
    Add-Table 'Items' { SmallMoney 'Price' -Sparse }

    Demonstrates how to create a sparse, optional `smallmoney` column called `Price`.

    .EXAMPLE
    Add-Table 'Items' { SmallMoney 'Price' -NotNull -Default '0.00' }

    Demonstrates how to create a required `smallmoney` column called `Price` with a default value of `$0.00`.

    .EXAMPLE
    Add-Table 'Items' { SmallMoney 'Price' -NotNull -Description 'The price of the item.' }

    Demonstrates how to create a required `smallmoney` column with a description.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Mandatory,ParameterSetName='NotNull')]
        # Don't allow `NULL` values in this column.
        [switch]$NotNull,

        [Parameter(ParameterSetName='Nullable')]
        # Store nulls as Sparse.
        [switch]$Sparse,

        # A SQL Server expression for the column's default value 
        [String]$Default,

        # The name of the default constraint for the column's default expression. Required if the Default parameter is given.
        [String]$DefaultConstraintName,
            
        # A description of the column.
        [String]$Description
    )
        
    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::SmallMoney($Name, $nullable, $Default, $DefaultConstraintName, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::SmallMoney($Name,'NotNull', $Default, $DefaultConstraintName, $Description)
        }
    }
}
    
Set-Alias -Name 'SmallMoney' -Value 'New-SmallMoneyColumn'