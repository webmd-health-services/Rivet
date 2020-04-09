function New-UniqueIdentifierColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an UniqueIdentifier datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'WithUUID' {
            UniqueIdentifier 'ColumnName'
        }

    ## ALIASES

     * UniqueIdentifier

    .EXAMPLE
    Add-Table Locations { UniqueIdentifier 'LocationID' }

    Demonstrates how to create a table with an optional `uniqueidentifier` column.

    .EXAMPLE
    Add-Table Locations { UniqueIdentifier 'LocationID' -RowGuidCol }

    Demonstrates how to create a table with an optional `uniqueidentifier`, which is used as the RowGuid identifier for SQL Server replication.

    .EXAMPLE
    Add-Table Locations { UniqueIdentifier 'LocationID' -NotNull }

    Demonstrates how to create a table with an required `uniqueidentifier` column.

    .EXAMPLE
    Add-Table Locations { UniqueIdentifier 'LocationID' -Default 'newid()' }

    Demonstrates how to create a table with an optional `uniqueidentifier` column with a default value.

    .EXAMPLE
    Add-Table Locations { UniqueIdentifier 'LocationID' -Description 'The unique identifier for this location.' }

    Demonstrates how to create a table with an optional `uniqueidentifier` column with a default value.
    #>
    [CmdletBinding(DefaultParameterSetName='Nullable')]
    param(
        [Parameter(Mandatory,Position=0)]
        # The column's name.
        [String]$Name,

        # Sets RowGuidCol
        [switch]$RowGuidCol,

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
            [Rivet.Column]::UniqueIdentifier($Name, $RowGuidCol, $nullable, $Default, $DefaultConstraintName, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::UniqueIdentifier($Name, $RowGuidCol, [Rivet.Nullable]::NotNull, $Default, $DefaultConstraintName, $Description)
        }
    }
}
    
Set-Alias -Name 'UniqueIdentifier' -Value 'New-UniqueIdentifierColumn'