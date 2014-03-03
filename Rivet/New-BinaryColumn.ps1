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

        [Parameter(Mandatory=$true,Position=1)]
        [Int]
        # The number of bytes the column will hold.
        $Size,

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

    $sizetype = New-Object Rivet.CharacterLength $Size

    $nullable = 'Null'
    if( $PSCmdlet.ParameterSetName -eq 'NotNull' )
    {
        $nullable = 'NotNull'
    }
    elseif( $Sparse )
    {
        $nullable = 'Sparse'
    }

    [Rivet.Column]::Binary($Name, $sizetype, $nullable, $Default, $Description)
}
    
Set-Alias -Name 'Binary' -Value 'New-BinaryColumn'