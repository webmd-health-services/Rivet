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
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Mandatory=$true,ParameterSetName='NotNull')]
        [Switch]
        # Don't allow `NULL` values in this column.
        $NotNull,

        [Parameter(ParameterSetName='Nullable')]
        [Switch]
        # Store nulls as Sparse.
        $Sparse,

        [Parameter()]
        [string]
        # A SQL Server expression for the column's default value 
        $Default,
            
        [Parameter()]
        [string]
        # A description of the column.
        $Description
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
            [Rivet.Column]::SmallMoney($Name, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::SmallMoney($Name,'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'SmallMoney' -Value 'New-SmallMoneyColumn'