function New-RowVersionColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an RowVersion datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'WithUUID' {
            RowVersion 'ColumnName'
        }

    ## ALIASES

     * RowVersion

    .EXAMPLE
    Add-Table Changes { RowVersion 'Version' }

    Demonstrates how to create a table with an optional `rowversion` column.

    .EXAMPLE
    Add-Table Locations { RowVersion 'LocationID' -RowGuidCol }

    Demonstrates how to create a table with an optional `rowversion`, which is used as the RowGuid identifier for SQL Server replication.

    .EXAMPLE
    Add-Table Locations { RowVersion 'LocationID' -NotNull }

    Demonstrates how to create a table with an required `rowversion` column.

    .EXAMPLE
    Add-Table Locations { RowVersion 'LocationID' -Default 'newid()' }

    Demonstrates how to create a table with an optional `rowversion` column with a default value.

    .EXAMPLE
    Add-Table Locations { RowVersion 'LocationID' -Description 'The unique identifier for this location.' }

    Demonstrates how to create a table with an optional `rowversion` column with a description.
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
            [Rivet.Column]::RowVersion($Name, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::RowVersion($Name,'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'RowVersion' -Value 'New-RowVersionColumn'