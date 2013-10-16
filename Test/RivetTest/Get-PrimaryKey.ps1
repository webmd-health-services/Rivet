
function Get-PrimaryKey
{
    <#
    .SYNOPSIS
    Gets objects for all the columns that are part of a a table's primary key.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table whose primary key to get.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo'
    )

    Set-StrictMode -Version Latest
    
    $query = @'
    SELECT
       s.name SchemaName, ta.name  TableName, col.name ColumnName, ind.*, indcol.*
     from sys.tables ta 
      inner join sys.schemas s on s.schema_id = ta.schema_id
      inner join sys.indexes ind on ind.object_id = ta.object_id
      inner join sys.index_columns indcol on indcol.object_id = ta.object_id and indcol.index_id = ind.index_id 
      inner join sys.columns col on col.object_id = ta.object_id and col.column_id = indcol.column_id
     where ind.is_primary_key = 1 and ta.name = '{0}' and s.name = '{1}'
     order by
       ta.name, indcol.key_ordinal
'@ -f $TableName,$SchemaName
    
    Invoke-RivetTestQuery -Query $query
}