
function Get-Column
{
    param(
        [Parameter(Position=0, Mandatory)]
        [String] $Name,

        [Parameter(Mandatory)]
        $TableName,

        [Alias('TableSchema')]
        $SchemaName = 'dbo',

        [String] $DatabaseName
    )

    Set-StrictMode -Version Latest

    $query = @'
    select
        ty.name type_name,
        c.*,
        ex.value MSDescription,
        dc.name default_constraint_name,
        dc.definition default_constraint,
        ic.seed_value,
        ic.increment_value,
        ic.is_not_for_replication
    from sys.columns c join
        sys.tables t on c.object_id = t.object_id join
        sys.schemas s on t.schema_id = s.schema_id join
        sys.types ty on c.user_type_id = ty.user_type_id left outer join
        sys.extended_properties ex on ex.major_id = c.object_id and ex.minor_id = c.column_id and OBJECTPROPERTY(c.object_id, 'IsMsShipped') = 0 and ex.name = '{0}' left outer join
        sys.default_constraints dc on c.object_id = dc.parent_object_id and c.column_id = dc.parent_column_id left outer join
        sys.identity_columns ic on c.object_id = ic.object_id and c.column_id = ic.column_id
    where
        s.name = '{1}' and t.name = '{2}' and c.name = '{3}'
'@ -f [Rivet.Operations.ExtendedPropertyOperation]::DescriptionPropertyName, $SchemaName, $TableName, $Name
    Invoke-RivetTestQuery -Query $query -DatabaseName $DatabaseName
}
