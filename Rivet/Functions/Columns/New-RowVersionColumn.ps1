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
            [Rivet.Column]::RowVersion($Name, $nullable, $Default, $DefaultConstraintName, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::RowVersion($Name,'NotNull', $Default, $DefaultConstraintName, $Description)
        }
    }
}
    
Set-Alias -Name 'RowVersion' -Value 'New-RowVersionColumn'