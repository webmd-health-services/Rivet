function New-IntColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an Int datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Items' {
            Int 'Quantity'
        }

    ## ALIASES

     * Int

    .EXAMPLE
    Add-Table 'Items' { Int 'Quantity' }

    Demonstrates how to create an optional `int` column called `Quantity`.

    .EXAMPLE
    Add-Table 'Items' { Int 'Quantity' -Identity 1 1 }

    Demonstrates how to create a required `int` column called `Quantity`, which is used as the table's identity.  The identity values will start at 1, and increment by 1.

    .EXAMPLE
    Add-Table 'Items' { Int 'Quantity' -NotNull }

    Demonstrates how to create a required `int` column called `Quantity`.

    .EXAMPLE
    Add-Table 'Items' { Int 'Quantity' -Sparse }

    Demonstrates how to create a sparse, optional `int` column called `Quantity`.

    .EXAMPLE
    Add-Table 'Items' { Int 'Quantity' -NotNull -Default '0' }

    Demonstrates how to create a required `int` column called `Quantity` with a default value of `0`.

    .EXAMPLE
    Add-Table 'Items' { Int 'Quantity' -NotNull -Description 'The number of items currently on hand.' }

    Demonstrates how to create a required `int` column with a description.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Mandatory,ParameterSetName='Identity')]
        [Parameter(Mandatory,ParameterSetName='IdentityWithSeed')]
        # The column should be an identity.
        [switch]$Identity,

        [Parameter(Mandatory,ParameterSetName='IdentityWithSeed',Position=1)]
        # The starting value for the identity.
        [int]$Seed,

        [Parameter(Mandatory,ParameterSetName='IdentityWithSeed',Position=2)]
        # The increment between auto-generated identity values.
        [int]$Increment,

        [Parameter(ParameterSetName='Identity')]
        [Parameter(ParameterSetName='IdentityWithSeed')]
        # Stops the identity from being replicated.
        [switch]$NotForReplication,

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
            [Rivet.Column]::Int($Name, $nullable, $Default, $DefaultConstraintName, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::Int($Name,'NotNull', $Default, $DefaultConstraintName, $Description)
        }

        'Identity'
        {
            $i = New-Object 'Rivet.Identity' $NotForReplication
            [Rivet.Column]::Int( $Name, $i, $Description )
        }

        'IdentityWithSeed'
        {
            $i = New-Object 'Rivet.Identity' $Seed, $Increment, $NotForReplication
            [Rivet.Column]::Int( $Name, $i, $Description )
        }

            
    }
}
    
Set-Alias -Name 'Int' -Value 'New-IntColumn'