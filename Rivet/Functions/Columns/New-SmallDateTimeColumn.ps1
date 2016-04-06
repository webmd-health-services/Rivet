function New-SmallDateTimeColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an SmallDateTime datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Orders' {
            SmallDateTime 'OrderedAt'
        }

    ## ALIASES

     * SmallDateTime

    .EXAMPLE
    Add-Table 'Orders' { New-SmallDateTimeColumn 'OrderedAt' -NotNull }

    Demonstrates how to create a required `smalldatetime` colum when adding a new table.

    .EXAMPLE
    Add-Table 'Orders' { SmallDateTime 'OrderedAt' -Sparse }

    Demonstrate show to create a nullable, sparse `smalldatetime` column when adding a new table.

    .EXAMPLE
    Add-Table 'Orders' { SmallDateTime 'OrderedAt' -NotNull -Default 'getutcdate()' }

    Demonstrates how to create a `smalldatetime` column with a default value.  You only use UTC dates, right?

    .EXAMPLE
    Add-Table 'Orders' { SmallDateTime 'OrderedAt' -NotNull -Description 'The time the record was created.' }

    Demonstrates how to create a `smalldatetime` column a description.
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
        [string]
        # A SQL Server expression for the column's default value 
        $Default,
            
        [Parameter()]
        [string]
        # A description of the column.
        $Description
    )
 
    switch ($PSCmdlet.ParameterSetName)
    {
        'Nullable'
        {
            $nullable = 'Null'
            if( $Sparse )
            {
                $nullable = 'Sparse'
            }
            [Rivet.Column]::SmallDateTime($Name, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::SmallDateTime($Name,'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'SmallDateTime' -Value 'New-SmallDateTimeColumn'