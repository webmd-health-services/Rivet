
function Get-Table
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table to get.
        $Name,
        
        [string]
        # The table's schema.  Default is `dbo`.
        $SchemaName = 'dbo'
    )

    Set-StrictMode -Version Latest
        $query = @'
    select 
        t.*, p.data_compression, ex.value MSDescription
    from sys.tables t join 
        sys.partitions p on p.object_id=t.object_id join
        sys.schemas s on t.schema_id = s.schema_id left outer join
        sys.extended_properties ex on ex.major_id = t.object_id and minor_id = 0 and OBJECTPROPERTY(t.object_id, 'IsMsShipped') = 0 and ex.name = '{0}' 
    where
        s.name = '{1}' and t.name = '{2}'
'@ -f [Rivet.Operations.ExtendedPropertyOperation]::DescriptionPropertyName, $SchemaName, $Name

    Invoke-RivetTestQuery -Query $query

}
