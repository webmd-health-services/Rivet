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
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Mandatory,Position=1)]
        # The number of bytes the column will hold.
        [int]$Size,

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

    [Rivet.Column]::Binary($Name, $sizetype, $nullable, $Default, $DefaultConstraintName, $Description)
}
    
Set-Alias -Name 'Binary' -Value 'New-BinaryColumn'