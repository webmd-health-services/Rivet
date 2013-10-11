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
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Position=1)]
        [Int]
        # Defines the string Size of the fixed-Size string data.
        $Size = 30,

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

    if ($NotNull -and $Sparse)
    {
        throw ('Column {0}: A column cannot be NOT NULL and SPARSE.  Please choose one, but not both' -f $Name)
        return
    }
        
    $Sizetype = $null

    $Sizetype = New-Object Rivet.CharacterLength $Size

    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::Char($Name, $Sizetype, $Collation, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::Char($Name,$Sizetype, $Collation, 'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'Char' -Value 'New-CharColumn'