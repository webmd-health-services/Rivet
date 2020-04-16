function New-BitColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an Bit datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Items' {
            Bit 'IsAvailable'
        }

    ## ALIASES

     * Bit

    .EXAMPLE
    Add-Table 'Items' { Bit 'IsAvailable' }

    Demonstrates how to create an optional `bit` column called `IsAvailable`.

    .EXAMPLE
    Add-Table 'Items' { Bit 'IsAvailable' -NotNull }

    Demonstrates how to create a required `bit` column called `IsAvailable`.

    .EXAMPLE
    Add-Table 'Items' { Bit 'IsAvailable' -Sparse }

    Demonstrates how to create a sparse, optional `bit` column called `IsAvailable`.

    .EXAMPLE
    Add-Table 'Items' { Bit 'IsAvailable' -NotNull -Default '1' }

    Demonstrates how to create a required `bit` column called `IsAvailable` with a default value of `1`.

    .EXAMPLE
    Add-Table 'Items' { Bit 'IsAvailable' -NotNull -Description 'The price of the item.' }

    Demonstrates how to create a required `bit` column with a description.
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
            [Rivet.Column]::Bit($Name, $nullable, $Default, $DefaultConstraintName, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::Bit($Name,'NotNull', $Default, $DefaultConstraintName, $Description)
        }
    }
}
    
Set-Alias -Name 'Bit' -Value 'New-BitColumn'