function New-NVarCharColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an NVarChar datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table -Name 'Albums' -Column {
            NVarChar 'Name' 50
        }

    ## ALIASES

     * NVarChar

    .EXAMPLE
    Add-Table 'Albums' { NVarChar 'Name' 100 } 

    Demonstrates how to create an optional `nvarchar` column with a maximum length of 100 bytes.

    .EXAMPLE
    Add-Table 'Albums' { NVarChar 'Name' 100 -NotNull }

    Demonstrates how to create a required `nvarchar` column with maximum length of 100 bytes.

    .EXAMPLE
    Add-Table 'Albums' { NVarChar 'Name' -Max }

    Demonstrates how to create an optional `nvarchar` column with the maximum length (about 2GB).

    .EXAMPLE
    Add-Table 'Albums' { NVarChar 'Name' 100 -Collation 'Latin1_General_BIN' }

    Demonstrates now to create an optional `nvarchar` column with a custom `Latin1_General_BIN` collation.
    #>
    [CmdletBinding(DefaultParameterSetName='NullSize')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='NullSize')]
        [Parameter(Mandatory=$true,Position=1,ParameterSetName='NotNullSize')]
        [Alias('Length')]
        [Int]
        # The maximum length of the column, i.e. the number of unicode characters.
        $Size,

        [Parameter(Mandatory=$true,ParameterSetName='NullMax')]
        [Parameter(Mandatory=$true,ParameterSetName='NotNullMax')]
        [Switch]
        # Create an `nvarchar(max)` column.
        $Max,

        [Parameter()]
        [string]
        # Controls the code page that is used to store the data
        $Collation,

        [Parameter(Mandatory=$true,ParameterSetName='NotNullSize')]
        [Parameter(Mandatory=$true,ParameterSetName='NotNullMax')]
        [Switch]
        # Don't allow `NULL` values in this column.
        $NotNull,

        [Parameter(ParameterSetName='NullSize')]
        [Parameter(ParameterSetName='NullMax')]
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

    $sizeType = $null
    if( $PSCmdlet.ParameterSetName -like '*Size' )
    {
        $sizeType = New-Object Rivet.CharacterLength $Size
    }
    else 
    {
        $sizeType = New-Object Rivet.CharacterLength @()   
    }

    $nullable = 'Null'
    if( $PSCmdlet.ParameterSetName -like 'NotNull*' )
    {
        $nullable = 'NotNull'
    }
    elseif( $Sparse )
    {
        $nullable = 'Sparse'
    }

    [Rivet.Column]::NVarChar($Name, $sizeType, $Collation, $nullable, $Default, $Description)
}
    
Set-Alias -Name 'NVarChar' -Value 'New-NVarCharColumn'