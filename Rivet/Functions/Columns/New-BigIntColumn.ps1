function New-BigIntColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an BigInt datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Migrations' {
            BigInt 'MigrationID'
        }

    ## ALIASES

     * BigInt

    .EXAMPLE
    Add-Table 'Migrations' { BigInt 'MigrationID' }

    Demonstrates how to create an optional `bigint` column called `MigrationID`.

    .EXAMPLE
    Add-Table 'Migrations' { BigInt 'ID' -Identity 1 1 }

    Demonstrates how to create a required `bigint` column called `ID`, which is used as the table's identity.  The identity values will start at 1, and increment by 1.

    .EXAMPLE
    Add-Table 'Migrations' { BigInt 'MigrationID' -NotNull }

    Demonstrates how to create a required `bigint` column called `MigrationID`.

    .EXAMPLE
    Add-Table 'Migrations' { BigInt 'MigrationID' -Sparse }

    Demonstrates how to create a sparse, optional `bigint` column called `MigrationID`.

    .EXAMPLE
    Add-Table 'Migrations' { BigInt 'MigrationID' -NotNull -Default '0' }

    Demonstrates how to create a required `bigint` column called `MigrationID` with a default value of `0`.

    .EXAMPLE
    Add-Table 'Migrations' { BigInt 'MigrationID' -NotNull -Description 'The number of items currently on hand.' }

    Demonstrates how to create a required `bigint` column with a description.
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

        # A SQL Server expression for the column's default value. The DefaultConstraintName parameter is required if this parameter is used.
        [String]$Default,

        # The name of the default constraint for the column's default expression. Required if the Default parameter is given.
        [String]$DefaultConstraintName,

        # A description of the column.
        [String]$Description
    )

    Set-StrictMode -Version 'Latest'

    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::BigInt($Name, $nullable, $Default, $DefaultConstraintName, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::BigInt($Name,'NotNull', $Default, $DefaultConstraintName, $Description)
        }

        'Identity'
        {
            $i = New-Object 'Rivet.Identity' $NotForReplication
            [Rivet.Column]::BigInt( $Name, $i, $Description )
        }

        'IdentityWithSeed'
        {
            $i = New-Object 'Rivet.Identity' $Seed, $Increment, $NotForReplication
            [Rivet.Column]::BigInt( $Name, $i, $Description )
        }
    }
}

Set-Alias -Name 'BigInt' -Value 'New-BigIntColumn'