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
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='NullSize')]
        [Parameter(Mandatory=$true,Position=1,ParameterSetName='NotNullSize')]
        [Int]
        # The maximum number of bytes the column will hold.
        $Size,

        [Parameter(Mandatory=$true,ParameterSetName='NullMax')]
        [Parameter(Mandatory=$true,ParameterSetName='NotNullMax')]
        [Switch]
        # Creates a `varbinary(max)` column.
        $Max,

        [Parameter(ParameterSetName='NullMax')]
        [Parameter(ParameterSetName='NotNullMax')]
        [Switch]
        # Stores the varbinary(max) data in a filestream data container on the file system.  Requires VarBinary(max).
        $FileStream,

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

    [Rivet.Column]::VarBinary($Name, $sizeType, $FileStream, $nullable, $Default, $Description)
}
    
Set-Alias -Name 'VarBinary' -Value 'New-VarBinaryColumn'