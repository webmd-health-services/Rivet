function New-DecimalColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an Decimal datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Items' {
            Decimal 'Price'
        }

    ## ALIASES

     * Decimal
     * Numeric
     * New-NumericColumn

    .EXAMPLE
    Add-Table 'Items' { Decimal 'Price' -Precision 5 -Scale 2 }

    Demonstrates how to create an optional `decimal` column called `Price`, with a five-digit precision (prices less than $999.99) and a scale of 2 (2 digits after the `decimal`).

    .EXAMPLE
    Add-Table 'Items' { Decimal 'Price' -Identity 1 1 }

    Demonstrates how to create a required `decimal` column called `Price`, which is used as the table's identity.  The identity values will start at 1, and increment by 1. Uses SQL Server's default precision/scale.

    .EXAMPLE
    Add-Table 'Items' { Decimal 'Price' -NotNull }

    Demonstrates how to create a required `decimal` column called `Price`. Uses SQL Server's default precision/scale.

    .EXAMPLE
    Add-Table 'Items' { Decimal 'Price' -Sparse }

    Demonstrates how to create a sparse, optional `decimal` column called `Price`. Uses SQL Server's default precision/scale.

    .EXAMPLE
    Add-Table 'Items' { Decimal 'Price' -NotNull -Default '0' }

    Demonstrates how to create a required `decimal` column called `Price` with a default value of `0`. Uses SQL Server's default precision/scale.

    .EXAMPLE
    Add-Table 'Items' { Decimal 'Price' -NotNull -Description 'The price of the item.' }

    Demonstrates how to create a required `decimal` column with a description. Uses SQL Server's default precision/scale.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Mandatory=$true,ParameterSetName='Identity')]
        [Parameter(Mandatory=$true,ParameterSetName='IdentityWithSeed')]
        [Switch]
        # The column should be an identity.
        $Identity,

        [Parameter(Mandatory=$true,ParameterSetName='IdentityWithSeed',Position=1)]
        [int]
        # The starting value for the identity.
        $Seed,

        [Parameter(Mandatory=$true,ParameterSetName='IdentityWithSeed',Position=2)]
        [int]
        # The increment between auto-generated identity values.
        $Increment,

        [Parameter(ParameterSetName='Identity')]
        [Parameter(ParameterSetName='IdentityWithSeed')]
        [Switch]
        # Stops the identity from being replicated.
        $NotForReplication,

        [Parameter(Mandatory=$true,ParameterSetName='NotNull')]
        [Switch]
        # Don't allow `NULL` values in this column.
        $NotNull,

        [Parameter(ParameterSetName='Nullable')]
        [Switch]
        # Store nulls as Sparse.
        $Sparse,

        [Parameter(Mandatory=$true)]
        [Int]
        # Maximum total number of decimal digits that will be stored
        $Precision,

        [Parameter()]
        [Int]
        # The number of decimal digits that will be stored to the right of the decimal point
        $Scale = 0,

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
        
    $dataSize = $null

    $dataSize = New-Object Rivet.PrecisionScale $Precision, $Scale

    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::Decimal($Name, $dataSize, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::Decimal($Name, $dataSize, 'NotNull', $Default, $Description)
        }

        'Identity'
        {
            $i = New-Object 'Rivet.Identity' $NotForReplication
            [Rivet.Column]::Decimal( $Name, $dataSize, $i, $Description )
        }

        'IdentityWithSeed'
        {
            $i = New-Object 'Rivet.Identity' $Seed, $Increment, $NotForReplication
            [Rivet.Column]::Decimal( $Name, $dataSize, $i, $Description )
        }

            
    }
}
    
Set-Alias -Name 'Decimal' -Value 'New-DecimalColumn'
