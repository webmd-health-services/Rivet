function New-TinyIntColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an TinyInt datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'WithTintyInt' {
            TinyInt 'ColumnName'
        }

    ## ALIASES

     * TinyInt

    .EXAMPLE
    Add-Table 'Items' { TinyInt 'Quantity' }

    Demonstrates how to create an optional `tinyint` column called `Quantity`.

    .EXAMPLE
    Add-Table 'Items' { TinyInt 'Quantity' -Identity 1 1 }

    Demonstrates how to create a required `tinyint` column called `Quantity`, which is used as the table's identity.  The identity values will start at 1, and increment by 1.

    .EXAMPLE
    Add-Table 'Items' { TinyInt 'Quantity' -NotNull }

    Demonstrates how to create a required `tinyint` column called `Quantity`.

    .EXAMPLE
    Add-Table 'Items' { TinyInt 'Quantity' -Sparse }

    Demonstrates how to create a sparse, optional `tinyint` column called `Quantity`.

    .EXAMPLE
    Add-Table 'Items' { TinyInt 'Quantity' -NotNull -Default '0' }

    Demonstrates how to create a required `tinyint` column called `Quantity` with a default value of `0`.

    .EXAMPLE
    Add-Table 'Items' { TinyInt 'Quantity' -NotNull -Description 'The number of items currently on hand.' }

    Demonstrates how to create a required `tinyint` column with a description.
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
            [Rivet.Column]::TinyInt($Name, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::TinyInt($Name,'NotNull', $Default, $Description)
        }

        'Identity'
        {
            $i = New-Object 'Rivet.Identity' $NotForReplication
            [Rivet.Column]::TinyInt( $Name, $i, $Description )
        }

        'IdentityWithSeed'
        {
            $i = New-Object 'Rivet.Identity' $Seed, $Increment, $NotForReplication
            [Rivet.Column]::TinyInt( $Name, $i, $Description )
        }

            
    }
}
    
Set-Alias -Name 'TinyInt' -Value 'New-TinyIntColumn'