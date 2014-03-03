
function Get-Column
{
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]
        $Name,

        [Parameter(Mandatory=$true)]
        $TableName,

        [Alias('TableSchema')]
        $SchemaName = 'dbo'
    )
    
    Set-StrictMode -Version Latest

    $query = @'
    select 
        ty.name type_name, c.*, ex.value MSDescription, dc.name default_constraint_name, dc.definition default_constraint, ic.seed_value, ic.increment_value, ic.is_not_for_replication
    from sys.columns c join 
        sys.tables t on c.object_id = t.object_id join 
        sys.schemas s on t.schema_id = s.schema_id join
        sys.types ty on c.user_type_id = ty.user_type_id left outer join
        sys.extended_properties ex on ex.major_id = c.object_id and ex.minor_id = c.column_id and OBJECTPROPERTY(c.object_id, 'IsMsShipped') = 0 and ex.name = 'MS_Description' left outer join
        sys.default_constraints dc on c.object_id = dc.parent_object_id and c.column_id = dc.parent_column_id left outer join
        sys.identity_columns ic on c.object_id = ic.object_id and c.column_id = ic.column_id
    where
        s.name = '{0}' and t.name = '{1}' and c.name = '{2}'
'@ -f $SchemaName, $TableName, $Name
    Invoke-RivetTestQuery -Query $query -Connection $RTDatabaseConnection
}
