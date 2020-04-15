function New-DateTimeOffsetColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an DateTimeOffset datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Orders' {
            DateTimeOffset 'OrderedAt'
        }

    ## ALIASES

     * DateTimeOffset

    .EXAMPLE
    Add-Table 'Orers' { DateTimeOffset 'OrderedAt' }

    Demonstrates how to create an optional `datetimeoffset` column.

    .EXAMPLE
    Add-Table 'Orders' { DateTimeOffset 'OrderedAt' 5 -NotNull }

    Demonstrates how to create a required `datetimeoffset` column with a digits of fractional seconds precision.

    .EXAMPLE
    Add-Table 'Orders' { DateTimeOffset 'OrderedAt' -Sparse }

    Demonstrate show to create a nullable, sparse `datetimeoffset` column when adding a new table.

    .EXAMPLE
    Add-Table 'Orders' { DateTimeOffset 'OrderedAt' -NotNull -Default 'getutcdate()' }

    Demonstrates how to create a `datetimeoffset` column with a default value.  You only use UTC dates, right?

    .EXAMPLE
    Add-Table 'Orders' { DateTimeOffset 'OrderedAt' -NotNull -Description 'The time the record was created.' }

    Demonstrates how to create a `datetimeoffset` column with a description.
    #>
    [CmdletBinding(DefaultParameterSetName='Null')]
    param(
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Position=1)]
        [Alias('Precision')]
        # The number of decimal digits for the fractional seconds. SQL Server's default is `7`, or 100 nanoseconds.
        [int]$Scale,

        [Parameter(Mandatory,ParameterSetName='NotNull')]
        # Don't allow `NULL` values in this column.
        [switch]$NotNull,

        [Parameter(ParameterSetName='Null')]
        # Store nulls as Sparse.
        [switch]$Sparse,

        # A SQL Server expression for the column's default value 
        [String]$Default,

        # The name of the default constraint for the column's default expression. Required if the Default parameter is given.
        [String]$DefaultConstraintName,
            
        # A description of the column.
        [String]$Description
    )

    $dataSize = $null
    if( $PSBoundParameters.ContainsKey('Scale') )
    {
        $dataSize = New-Object Rivet.Scale $Scale
    }
     
    $nullable = $PSCmdlet.ParameterSetName
    if( $nullable -eq 'Null' -and $Sparse )
    {
        $nullable = 'Sparse'
    }

    [Rivet.Column]::DateTimeOffset($Name, $dataSize, $nullable, $Default, $DefaultConstraintName, $Description)
}
    
Set-Alias -Name 'DateTimeOffset' -Value 'New-DateTimeOffsetColumn'