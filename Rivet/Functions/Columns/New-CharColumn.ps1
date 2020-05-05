function New-CharColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an Char datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table -State 'Addresses' -Column {
            Char 'State' 2
        }

    ## ALIASES

     * Char

    .EXAMPLE
    Add-Table 'Addresses' { Char 'State' 2 } 

    Demonstrates how to create an optional `char` column with a length of 2 bytes.

    .EXAMPLE
    Add-Table 'Addresses' { Char 'State' 2 -NotNull }

    Demonstrates how to create a required `char` column with length of 2 bytes.

    .EXAMPLE
    Add-Table 'Addresses' { Char 'State' 2 -Collation 'Latin1_General_BIN' }

    Demonstrates now to create an optional `char` column with a custom `Latin1_General_BIN` collation.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Mandatory,Position=1)]
        [Alias('Length')]
        # The length of the column, i.e. the number of characters.
        [int]$Size,

        # Controls the code page that is used to store the data
        [String]$Collation,

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

    $Sizetype = $null

    $Sizetype = New-Object Rivet.CharacterLength $Size

    $nullable = 'Null'
    if( $PSCmdlet.ParameterSetName -eq 'NotNull' )
    {
        $nullable = 'NotNull'
    }
    elseif( $Sparse )
    {
        $nullable = 'Sparse'
    }

    [Rivet.Column]::Char($Name, $Sizetype, $Collation, $nullable, $Default, $DefaultConstraintName, $Description)
}
    
Set-Alias -Name 'Char' -Value 'New-CharColumn'