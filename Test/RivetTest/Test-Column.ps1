
function Test-Column
{
    <#
    .SYNOPSIS
    Tests if column exists on a table.

    .DESCRIPTION
    Returns `True` if the column exists, `False` otherwise.

    .EXAMPLE
    Test-Column -Name 'CreatedAt' -TableName 'Customers'

    REturns `True` if the `Customers` table contains a `CreatedAt` column.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the column.
        $Name,

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table.
        $TableName,

        [string]
        # The name of the table's schema. Default is `dbo`.
        $TableSchema = 'dbo'
    )

    $query = @'
    select 
        1
    from sys.columns c join 
        sys.tables t on c.object_id = t.object_id join 
        sys.schemas s on t.schema_id = s.schema_id
    where
        s.name = '{0}' and t.name = '{1}' and c.name = '{2}'
'@ -f $TableSchema, $TableName, $Name
    $column = Invoke-RivetTestQuery -Query $query -Connection $RTDatabaseConnection -AsScalar
    return ($column -eq 1)

}