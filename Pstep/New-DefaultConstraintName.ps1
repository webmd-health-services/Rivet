
function New-DefaultConstraintName
{
    <#
    .SYNOPSIS
    Creates a default constraint name for a column in a table.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The column name.
        $ColumnName,

        [Parameter(Mandatory=$true)]
        [string]
        # The table name.
        $TableName,

        [Parameter()]
        [string]
        # The table's schema.  Default is `dbo`.
        $SchemaName = 'dbo'
    )

    $dfConstraintName = 'DF_{0}_{1}_{2}' -f $SchemaName,$TableName,$ColumnName
    if( $SchemaName -eq 'dbo' )
    {
        $dfConstraintName = 'DF_{0}_{1}' -f $TableName,$ColumnName
    }
    return $dfConstraintName
}