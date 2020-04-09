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
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        [Parameter(Mandatory,ParameterSetName='NotNull')]
        # Don't allow `NULL` values in this column.
        [switch]$NotNull,

        [Parameter(ParameterSetName='Nullable')]
        # Store nulls as Sparse.
        [switch]$Sparse,

        # A SQL Server expression for the column's default value 
        [String]$Default,

        # The name of the default constraint for the column's default expression. Required if the Default parameter is given.
        [String]$DefaultConstraintName,
            
        # A description of the column.
        [String]$Description
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
            [Rivet.Column]::SmallDateTime($Name, $nullable, $Default, $DefaultConstraintName, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::SmallDateTime($Name,'NotNull', $Default, $DefaultConstraintName, $Description)
        }
    }
}
    
Set-Alias -Name 'SmallDateTime' -Value 'New-SmallDateTimeColumn'