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
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Mandatory,Position=1,ParameterSetName='NullSize')]
        [Parameter(Mandatory,Position=1,ParameterSetName='NotNullSize')]
        [Alias('Length')]
        # The maximum length of the column, i.e. the number of unicode characters.
        [int]$Size,

        [Parameter(Mandatory,ParameterSetName='NullMax')]
        [Parameter(Mandatory,ParameterSetName='NotNullMax')]
        # Create an `nvarchar(max)` column.
        [switch]$Max,

        # Controls the code page that is used to store the data
        [String]$Collation,

        [Parameter(Mandatory,ParameterSetName='NotNullSize')]
        [Parameter(Mandatory,ParameterSetName='NotNullMax')]
        # Don't allow `NULL` values in this column.
        [switch]$NotNull,

        [Parameter(ParameterSetName='NullSize')]
        [Parameter(ParameterSetName='NullMax')]
        # Store nulls as Sparse.
        [switch]$Sparse,

        # A SQL Server expression for the column's default value 
        [String]$Default,

        # The name of the default constraint for the column's default expression. Required if the Default parameter is given.
        [String]$DefaultConstraintName,
            
        # A description of the column.
        [String]$Description
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

    [Rivet.Column]::NVarChar($Name, $sizeType, $Collation, $nullable, $Default, $DefaultConstraintName, $Description)
}
    
Set-Alias -Name 'NVarChar' -Value 'New-NVarCharColumn'