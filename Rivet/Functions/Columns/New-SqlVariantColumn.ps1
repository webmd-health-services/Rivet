function New-SqlVariantColumn
{
    <#
    .SYNOPSIS
    Creates a column object representing an SqlVariant datatype.

    .DESCRIPTION
    Use this function in the `Column` script block for `Add-Table`:

        Add-Table 'WithSqlVariant' {
            SqlVariant 'ColumnName'
        }

    ## ALIASES

     * SqlVariant

    .EXAMPLE
    Add-Table 'WithSqlVar' { SqlVariant 'WhoKnows' }

    Demonstrates how to create an optional `sql_variant` column called `WhoKnows`.

    .EXAMPLE
    Add-Table 'WithSqlVar' { SqlVariant 'WhoKnows' -NotNull }

    Demonstrates how to create a required `sql_variant` column called `WhoKnows`.

    .EXAMPLE
    Add-Table 'WithSqlVar' { SqlVariant 'WhoKnows' -Sparse }

    Demonstrates how to create a sparse, optional `sql_variant` column called `WhoKnows`.

    .EXAMPLE
    Add-Table 'WithSqlVar' { SqlVariant 'WhoKnows' -NotNull -Default '1' }

    Demonstrates how to create a required `sql_variant` column called `WhoKnows` with a default value of `1`.

    .EXAMPLE
    Add-Table 'WithSqlVar' { SqlVariant 'WhoKnows' -NotNull -Description 'The contents of this column are left as an exercise for the reader.' }

    Demonstrates how to create a required `sql_variant` column with a description.
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
            [Rivet.Column]::SqlVariant($Name, $nullable, $Default, $DefaultConstraintName, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::SqlVariant($Name,'NotNull', $Default, $DefaultConstraintName, $Description)
        }
    }
}
    
Set-Alias -Name 'SqlVariant' -Value 'New-SqlVariantColumn'