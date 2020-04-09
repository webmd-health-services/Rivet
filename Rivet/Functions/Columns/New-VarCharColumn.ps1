function New-VarCharColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an VarChar datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table -Name 'WithVarCharColumn' -Column {
            VarChar 'ColumnName' 50
        }

    ## ALIASES

     * VarChar

    .EXAMPLE
    Add-Table 'Albums' { VarChar 'Name' 100 } 

    Demonstrates how to create an optional `varchar` column with a maximum length of 100 bytes.

    .EXAMPLE
    Add-Table 'Albums' { VarChar 'Name' 100 -NotNull }

    Demonstrates how to create a required `varchar` column with maximum length of 100 bytes.

    .EXAMPLE
    Add-Table 'Albums' { VarChar 'Name' -Max }

    Demonstrates how to create an optional `varchar` column with the maximum length (about 2GB).

    .EXAMPLE
    Add-Table 'Albums' { VarChar 'Name' 100 -Collation 'Latin1_General_BIN' }

    Demonstrates now to create an optional `varchar` column with a custom `Latin1_General_BIN` collation.
    #>
    [CmdletBinding(DefaultParameterSetName='NullSize')]
    param(
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Mandatory,Position=1,ParameterSetName='NullSize')]
        [Parameter(Mandatory,Position=1,ParameterSetName='NotNullSize')]
        # The maximum length of the column, i.e. the number of characters.
        [int]$Size,

        [Parameter(Mandatory,ParameterSetName='NullMax')]
        [Parameter(Mandatory,ParameterSetName='NotNullMax')]
        # Create a `varchar(max)` column.
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

    [Rivet.Column]::VarChar($Name, $sizeType, $Collation, $nullable, $Default, $DefaultConstraintName, $Description)
}
    
Set-Alias -Name 'VarChar' -Value 'New-VarCharColumn'