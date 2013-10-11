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
            [Rivet.Column]::Bit($Name, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::Bit($Name,'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'Bit' -Value 'New-BitColumn'