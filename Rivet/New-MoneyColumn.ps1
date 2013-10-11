function New-MoneyColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an Money datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Items' {
            Money 'Price'
        }

    ## ALIASES

     * Money

    .EXAMPLE
    Add-Table 'Items' { Money 'Price' }

    Demonstrates how to create an optional `money` column called `Price`.

    .EXAMPLE
    Add-Table 'Items' { Money 'Price' -NotNull }

    Demonstrates how to create a required `money` column called `Price`.

    .EXAMPLE
    Add-Table 'Items' { Money 'Price' -Sparse }

    Demonstrates how to create a sparse, optional `money` column called `Price`.

    .EXAMPLE
    Add-Table 'Items' { Money 'Price' -NotNull -Default '0.00' }

    Demonstrates how to create a required `money` column called `Price` with a default value of `$0.00`.

    .EXAMPLE
    Add-Table 'Items' { Money 'Price' -NotNull -Description 'The price of the item.' }

    Demonstrates how to create a required `money` column with a description.
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

    if ($NotNull -and $Sparse)
    {
        throw ('Column {0}: A column cannot be NOT NULL and SPARSE.  Please choose one, but not both' -f $Name)
        return
    }
        
    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::Money($Name, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::Money($Name,'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'Money' -Value 'New-MoneyColumn'