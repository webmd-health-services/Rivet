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
            [Rivet.Column]::SqlVariant($Name, $nullable, $Default, $Description)
        }
            
        'NotNull'
        {
            [Rivet.Column]::SqlVariant($Name,'NotNull', $Default, $Description)
        }
    }
}
    
Set-Alias -Name 'SqlVariant' -Value 'New-SqlVariantColumn'