function New-NCharColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an NChar datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table -State 'Addresses' -Column {
            NChar 'State' 2
        }

    ## ALIASES

     * NChar

    .EXAMPLE
    Add-Table 'Addresses' { NChar 'State' 2 } 

    Demonstrates how to create an optional `nchar` column with a length of 2 bytes.

    .EXAMPLE
    Add-Table 'Addresses' { NChar 'State' 2 -NotNull }

    Demonstrates how to create a required `nchar` column with length of 2 bytes.

    .EXAMPLE
    Add-Table 'Addresses' { NChar 'State' 2 -Collation 'Latin1_General_BIN' }

    Demonstrates now to create an optional `nchar` column with a custom `Latin1_General_BIN` collation.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Mandatory=$true,Position=1)]
        [Int]
        # Defines the string Size of the fixed-Size string data.  Default is 30
        $Size,

        [Parameter()]
        [string]
        # Controls the code page that is used to store the data
        $Collation,

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
    [Rivet.Column]::NChar($Name, $Sizetype, $Collation, $nullable, $Default, $Description)
}
    
Set-Alias -Name 'NChar' -Value 'New-NCharColumn'