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
    [CmdletBinding(DefaultParameterSetName='Null')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Position=1)]
        [Alias('Precision')]
        [Int]
        # The number of decimal digits that will be stored for the fractional seconds. The default is `7`, which is 100 nanoseconds. Must be a value between 0 and 7.
        $Scale,

        [Parameter(Mandatory=$true,ParameterSetName='NotNull')]
        [Switch]
        # Don't allow `NULL` values in this column.
        $NotNull,

        [Parameter(ParameterSetName='Null')]
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

    $dataSize = $null
    # Yes. This is correct. Users can only specify the scale of a time column. Rivet's objects always store the precision,scale pair with precision first.d
    if( $PSBoundParameters.ContainsKey('Scale') )
    {
        $dataSize = New-Object Rivet.PrecisionScale $Scale
    }
    
    $nullable = $PSCmdlet.ParameterSetName
    if( $nullable -eq 'Null' -and $Sparse )
    {
        $nullable = 'Sparse'
    }

    [Rivet.Column]::Time($Name, $dataSize, $nullable, $Default, $Description)
}
    
Set-Alias -Name 'Time' -Value 'New-TimeColumn'