function New-TimeColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an Time datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'WithTime' {
            Time 'ColumnName'
        }

    ## ALIASES

     * Time

    .EXAMPLE
    Add-Table 'WithTime' { New-TimeColumn 'CreatedAt' 5 -NotNull }

    Demonstrates how to create a required `time` column with a given scale when adding a new table.

    .EXAMPLE
    Add-Table 'WithTime' { Time 'CreatedAt' -Sparse }

    Demonstrate show to create a nullable, sparse `time` column when adding a new table.

    .EXAMPLE
    Add-Table 'WithTime' { Time 'CreatedAt' -NotNull -Default 'convert(`time`, getutcdate())' }
    
    Demonstrates how to create a `time` column with a default value, in this case the current time.  You alwyas use UTC, right?

    .EXAMPLE
    Add-Table 'WithTime' { Time 'CreatedAt' -NotNull -Description 'The `time` the record was created.' }

    Demonstrates how to create a `time` column with a description.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Mandatory=$true,ParameterSetName='NotNull')]
        [Switch]
        # Don't allow `NULL` values in this column.
        $NotNull,

        [Parameter(ParameterSetName='Nullable')]
        [Switch]
        # Store nulls as Sparse.
        $Sparse,

        [Parameter()]
        [Int]
        # The number of decimal digits that will be stored to the right of the decimal point
        $Scale = 0,

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

    $dataSize = $null

    $dataSize = New-Object Rivet.PrecisionScale $Scale
        
    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::Time($Name, $dataSize, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::Time($Name,$dataSize, 'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'Time' -Value 'New-TimeColumn'