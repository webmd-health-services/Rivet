function New-BinaryColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an Binary datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Images' {
            Binary 'Bits' 256
        }

    ## ALIASES

     * Binary

    .EXAMPLE
    Add-Table 'Images' { Binary 'Bytes' 256 } 

    Demonstrates how to create an optional `binary` column with a maximum length of 256 bytes.

    .EXAMPLE
    Add-Table 'Images' { Binary 'Bytes' 256 -NotNull }

    Demonstrates how to create a required `binary` column with maximum length of 256 bytes.

    .EXAMPLE
    Add-Table 'Images' { Binary 'Bytes' -Max }

    Demonstrates how to create an optional `binary` column with the maximum length (2^31 -1 bytes).

    .EXAMPLE
    Add-Table 'Images' { Binary 'Bytes' -Max -FileStream }

    Demonstrates now to create an optional `binary` column with the maximum length, and stores the data in a filestream data container.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Position=1)]
        [Int]
        # Defines the Size
        $Size = 30,

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
        
    $Sizetype = $null

    $Sizetype = New-Object Rivet.CharacterLength $Size

    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::Binary($Name, $Sizetype, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::Binary($Name,$Sizetype, 'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'Binary' -Value 'New-BinaryColumn'