function New-FloatColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing a `float` datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Items' {
            Float 'Price'
        }

    ## ALIASES

     * Float

    .EXAMPLE
    Add-Table 'Items' { Float 'Price' -Precision 5  }

    Demonstrates how to create an optional `float` column called `Price`, with a precision of 5.

    .EXAMPLE
    Add-Table 'Items' { Float 'Price' -NotNull }

    Demonstrates how to create a required `float` column called `Price`. Uses SQL Server's default precision.

    .EXAMPLE
    Add-Table 'Items' { Float 'Price' -Sparse }

    Demonstrates how to create a sparse, optional `float` column called `Price`. Uses SQL Server's default precision.

    .EXAMPLE
    Add-Table 'Items' { Float 'Price' -NotNull -Default '0.0' }

    Demonstrates how to create a required `float` column called `Price` with a default value of `0`. Uses SQL Server's default precision.

    .EXAMPLE
    Add-Table 'Items' { Float 'Price' -NotNull -Description 'The price of the item.' }

    Demonstrates how to create a required `float` column with a description. Uses SQL Server's default precision.
    #>
    [CmdletBinding(DefaultParameterSetName='Null')]
    param(
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Position=1)]
        # Maximum total number of Numeric digits that will be stored
        [int]$Precision,

        [Parameter(Mandatory,ParameterSetName='NotNull')]
        # Don't allow `NULL` values in this column.
        [switch]$NotNull,

        [Parameter(ParameterSetName='Null')]
        # Store nulls as Sparse.
        [switch]$Sparse,

        # A SQL Server expression for the column's default value 
        [String]$Default,

        # The name of the default constraint for the column's default expression. Required if the Default parameter is given.
        [String]$DefaultConstraintName,
            
        # A description of the column.
        [String]$Description
    )

    $dataSize = $null

    if ($Precision -gt 0)
    {
        $dataSize = New-Object Rivet.PrecisionScale $Precision
    }
    
    $nullable = $PSCmdlet.ParameterSetName
    if( $nullable -eq 'Null' -and $Sparse )
    {
        $nullable = 'Sparse'
    }
    [Rivet.Column]::Float($Name, $dataSize, $nullable, $Default, $DefaultConstraintName, $Description)
}
    
Set-Alias -Name 'Float' -Value 'New-FloatColumn'