
function Get-DataType
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the data type.
        $Name,

        [string]
        # The name of the schema.
        $SchemaName
    )

    Set-StrictMode -Version 'Latest'

    $query = @'
        select 
            s.name schema_name, t.*, st.name base_type_name
        from
            sys.types t join
            sys.schemas s on t.schema_id = s.schema_id left outer join
            sys.types st on t.system_type_id = st.user_type_id
        where
            t.name = '{0}' and s.name = '{1}'
'@ -f $Name,$SchemaName

    Invoke-RivetTestQuery -Query $query
}
