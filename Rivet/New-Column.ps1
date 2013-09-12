function New-Column
{
    <#
    .SYNOPSIS
    Creates a column object of an explicit datatype which can be used with the `Add-Table` or `Add-Column` migrations.

    .DESCRIPTION
    Returns an object that can be used when adding columns or creating tables to get the SQL needed to create that column.  The returned object has the following members:

     * Name - the name of the column
     * Definition - the simplified column definition, with no default constraint
     * DefaultExpression - the expression for the default constraint, if any
     * GetColumnDefinition(string schemaName, string tableName) - Gets the full, complete table definition SQL used to create the column

    .EXAMPLE
    
    #>
    [CmdletBinding()]
    param(

        [Parameter(Mandatory=$true,Position=0,ParameterSetName='ExplicitDataType')]
        [string]
        # The Name of the new column.
        $Name,

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ExplicitDataType')]
        [string]
        # The datatype of the new column.
        $DataType,

        [Parameter(ParameterSetName='ExplicitDataType')]
        [Switch]
        # Optimizes the column storage for null values. Cannot be used with the `NotNull` switch.
        $Sparse,

        [Parameter(ParameterSetName='ExplicitDataType')]
        [Switch]
        # Makes the column not nullable.  Canno be used with the `Sparse` switch.
        $NotNull,

        [Object]
        # A SQL Server expression for the column's default value.
        $Default,

        [string]
        # A description of the column.
        $Description        
    )

    if( $PSBoundParameters.ContainsKey('NotNull') -and $PSBoundParameters.ContainsKey('Sparse') )
    {
        throw ('Column {0}: A column cannot be NOT NULL and SPARSE.  Please choose one switch: `NotNull` or `Sparse`, but not both.' -f $Name)
        return
    }

    $nullable = 'Null'
    if( $NotNull )
    {
        $nullable = 'NotNull'
    }
    elseif( $Sparse )
    {
        $nullable = 'Sparse'
    }


    switch ($PSCmdlet.ParameterSetName)
    {
        'ExplicitDataType'
        {
            New-Object Rivet.Column $Name,$DataType,$nullable,$Default,$Description
            break
        }
        default
        {
            $params = $PSBoundParameters.Keys | ForEach-Object { '{0}: {1}' -f $_,$PSBoundParameters.$_ }
            $params = $params -join '; '
            throw ('Unknown parameter set ''{0}'': @{{ {1} }}' -f $PSCmdlet.ParameterSetName,$params)
        }
    }
}