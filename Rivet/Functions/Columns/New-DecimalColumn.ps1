function New-DecimalColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing a `decimal` data type.

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
    Add-Table 'Items' { Decimal 'Price' 5 2 }

    Demonstrates how to create an optional `decimal` column called `Price`, with a five-digit precision (prices less than $999.99) and a scale of 2 (2 digits after the `decimal`).

    .EXAMPLE
    Add-Table 'Items' { Decimal 'Price' -Identity -Seed 1 -Increment 1 }

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
    [CmdletBinding(DefaultParameterSetName='Null')]
    param(
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Position=1)]
        # Maximum total number of decimal digits that will be stored.
        [int]$Precision,

        [Parameter(Position=2)]
        # The number of decimal digits that will be stored to the right of the decimal point.
        [int]$Scale,

        [Parameter(Mandatory,ParameterSetName='Identity')]
        # The column should be an identity.
        [switch]$Identity,

        [Parameter(ParameterSetName='Identity')]
        # The starting value for the identity.
        [int]$Seed,

        [Parameter(ParameterSetName='Identity')]
        # The increment between auto-generated identity values.
        [int]$Increment,

        [Parameter(ParameterSetName='Identity')]
        # Stops the identity from being replicated.
        [switch]$NotForReplication,

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
    if( $PSBoundParameters.ContainsKey( 'Precision' ) -and $PSBoundParameters.ContainsKey( 'Scale' ) )
    {
        $dataSize = New-Object Rivet.PrecisionScale $Precision, $Scale
    }
    elseif( $PSBoundParameters.ContainsKey( 'Precision' ) )
    {
        $dataSize = New-Object Rivet.PrecisionScale $Precision    
    }
    elseif( $PSBoundParameters.ContainsKey( 'Scale' ) )
    {
        throw ('New-DecimalColumn: a scale for column {0} is given, but no precision. Please remove the `-Scale` parameter, or add a `-Precision` parameter with a value.' -f $Name)
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        'Null'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::Decimal($Name, $dataSize, $nullable, $Default, $DefaultConstraintName, $Description)
            break
        }
            
        'NotNull'
        {
            [Rivet.Column]::Decimal($Name, $dataSize, 'NotNull', $Default, $DefaultConstraintName, $Description)
            break
        }

        'Identity'
        {
            if( $PSBoundParameters.ContainsKey('Seed') -and $PSBoundParameters.ContainsKey('Increment') )
            {
                $i = New-Object 'Rivet.Identity' $Seed,$Increment,$NotForReplication
            }
            elseif( $PSBoundParameters.ContainsKey('Seed') )
            {
                $i = New-Object 'Rivet.Identity' $Seed,1,$NotForReplication
            }
            elseif( $PSBoundParameters.ContainsKey('Increment') )
            {
                $i = New-Object 'Rivet.Identity' 1,$Increment,$NotForReplication
            }
            else
            {
                $i = New-Object 'Rivet.Identity' $NotForReplication
            }
            [Rivet.Column]::Decimal( $Name, $dataSize, $i, $Description )
            break
        }

    }
}
    
Set-Alias -Name 'Decimal' -Value 'New-DecimalColumn'
Set-Alias -Name 'Numeric' -Value 'New-DecimalColumn'
Set-Alias -Name 'New-NumericColumn' -Value 'New-DecimalColumn'

