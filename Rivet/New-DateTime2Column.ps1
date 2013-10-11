function New-DateTime2Column
{
    <#
    .SYNOPSIS
    Creates a column object representing an DateTime2 datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Orders' {
            DateTime2 'OrderedAt'
        }

    ## ALIASES

     * DateTime2

    .EXAMPLE
    Add-Table 'Orers' { DateTime2 'OrderedAt' }

    Demonstrates how to create an optional `datetime2` column.

    .EXAMPLE
    Add-Table 'Orders' { DateTime2 'OrderedAt' 5 -NotNull }

    Demonstrates how to create a required `datetime2` column with 5 digits of fractional seconds precision.

    .EXAMPLE
    Add-Table 'Orders' { DateTime2 'OrderedAt' -Sparse }

    Demonstrate show to create a nullable, sparse `datetime2` column when adding a new table.

    .EXAMPLE
    Add-Table 'Orders' { DateTime2 'OrderedAt' -NotNull -Default 'getutcdate()' }

    Demonstrates how to create a `datetime2` column with a default value.  You only use UTC dates, right?

    .EXAMPLE
    Add-Table 'Orders' { DateTime2 'OrderedAt' -NotNull -Description 'The time the record was created.' }

    Demonstrates how to create a `datetime2` column with a description.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Position=1)]
        [Int]
        # The number of decimal digits that will be stored to the right of the decimal point
        $Precision = 7,

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

    $dataSize = $null

    $dataSize = New-Object Rivet.PrecisionScale $Precision
        
    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::DateTime2($Name, $dataSize, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::DateTime2($Name, $dataSize, 'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'DateTime2' -Value 'New-DateTime2Column'