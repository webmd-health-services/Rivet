function New-DateTimeColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an DateTime datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'Orders' {
            DateTime 'OrderedAt'
        }

    ## ALIASES

     * DateTime

    .EXAMPLE
    Add-Table 'Orers' { DateTime 'OrderedAt' }

    Demonstrates how to create an optional `datetime` column.

    .EXAMPLE
    Add-Table 'Orders' { DateTime 'OrderedAt' 5 -NotNull }

    Demonstrates how to create a required `datetime` column with 5 digits of fractional seconds precision.

    .EXAMPLE
    Add-Table 'Orders' { DateTime 'OrderedAt' -Sparse }

    Demonstrate show to create a nullable, sparse `datetime` column when adding a new table.

    .EXAMPLE
    Add-Table 'Orders' { DateTime 'OrderedAt' -NotNull -Default 'getutcdate()' }

    Demonstrates how to create a `datetime` column with a default value.  You only use UTC dates, right?

    .EXAMPLE
    Add-Table 'Orders' { DateTime 'OrderedAt' -NotNull -Description 'The time the record was created.' }

    Demonstrates how to create a `datetime` column with a description.
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

    if ($PsCmdlet.ParameterSetName -eq 'Nullable')
    {
        if ($Sparse)
        {
            New-Column -Name $Name -DataType 'datetime' -Sparse -Default $Default -Description $Description
        }
        else {
            New-Column -Name $Name -DataType 'datetime' -Default $Default -Description $Description
        }
    }
    elseif ($PsCmdlet.ParameterSetName -eq 'NotNull')
    {
        New-Column -Name $Name -DataType 'datetime' -NotNull -Default $Default -Description $Description
    }
}
    
Set-Alias -Name 'DateTime' -Value 'New-DateTimeColumn'