function New-VarBinaryColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an VarBinary datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Images' {
            VarBinary 'Bits' 8000
        }

    ## ALIASES

     * VarBinary

    .EXAMPLE
    Add-Table 'Images' { VarBinary 'Bytes' 8000 } 

    Demonstrates how to create an optional `varbinary` column with a maximum length of 8000 bytes.

    .EXAMPLE
    Add-Table 'Images' { VarBinary 'Bytes' 8000 -NotNull }

    Demonstrates how to create a required `varbinary` column with maximum length of 8000 bytes.

    .EXAMPLE
    Add-Table 'Images' { VarBinary 'Bytes' -Max }

    Demonstrates how to create an optional `varbinary` column with the maximum length (2^31 -1 bytes).

    .EXAMPLE
    Add-Table 'Images' { VarBinary 'Bytes' -Max -FileStream }

    Demonstrates now to create an optional `varbinary` column with the maximum length, and stores the data in a filestream data container.
    #>
    [CmdletBinding(DefaultParameterSetName='NullSize')]
    param(
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Mandatory,Position=1,ParameterSetName='NullSize')]
        [Parameter(Mandatory,Position=1,ParameterSetName='NotNullSize')]
        # The maximum number of bytes the column will hold.
        [int]$Size,

        [Parameter(Mandatory,ParameterSetName='NullMax')]
        [Parameter(Mandatory,ParameterSetName='NotNullMax')]
        # Creates a `varbinary(max)` column.
        [switch]$Max,

        [Parameter(ParameterSetName='NullMax')]
        [Parameter(ParameterSetName='NotNullMax')]
        # Stores the varbinary(max) data in a filestream data container on the file system.  Requires VarBinary(max).
        [switch]$FileStream,

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

    [Rivet.Column]::VarBinary($Name, $sizeType, $FileStream, $nullable, $Default, $DefaultConstraintName, $Description)
}
    
Set-Alias -Name 'VarBinary' -Value 'New-VarBinaryColumn'