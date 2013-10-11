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
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Position=1)]
        [Int]
        # Defines the string Size of the variable-Size string data.
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

    if ($NotNull -and $Sparse)
    {
        throw ('Column {0}: A column cannot be NOT NULL and SPARSE.  Please choose one, but not both' -f $Name)
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
            [Rivet.Column]::VarChar($Name, $Sizetype, $Collation, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::VarChar($Name, $Sizetype, $Collation, 'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'VarChar' -Value 'New-VarCharColumn'