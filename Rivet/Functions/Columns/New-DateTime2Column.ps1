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
    [CmdletBinding(DefaultParameterSetName='Null')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The column's name.
        $Name,

        [Parameter(Position=1)]
        [Alias('Precision')]
        [Int]
        # The number of decimal digits for the fractional seconds. SQL Server's default is `7`, or 100 nanoseconds.
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
    if( $PSBoundParameters.ContainsKey( 'Scale' ) )
    {
        $dataSize = New-Object Rivet.Scale $Scale
    }
     
    $nullable = $PSCmdlet.ParameterSetName
    if( $nullable -eq 'Null' -and $Sparse )
    {
        $nullable = 'Sparse'
    }

    [Rivet.Column]::DateTime2($Name, $dataSize, $nullable, $Default, $Description)
}
    
Set-Alias -Name 'DateTime2' -Value 'New-DateTime2Column'