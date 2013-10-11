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
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Position=1)]
        [Int]
        # Defines the Size
        $Size,

        [Parameter()]
        [Switch]
        # Stores the varbinary(max) data in a filestream data container on the file system.  Requires VarBinary(max).
        $FileStream,

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

    if ($FileStream -and ($Size -ne 0))
    {
        throw ('Column {0}: FileStream requires VarBinary(max)' -f $Name)
        return
    }
        
    $Sizetype = $null

    if ($Size -ne 0)
    {
        $Sizetype = New-Object Rivet.CharacterLength $Size
    }
    else 
    {
        $Sizetype = New-Object Rivet.CharacterLength @()   
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::VarBinary($Name, $Sizetype, $FileStream, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::VarBinary($Name,$Sizetype, $FileStream, 'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'VarBinary' -Value 'New-VarBinaryColumn'