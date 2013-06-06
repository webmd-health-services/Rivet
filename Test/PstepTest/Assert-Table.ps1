
function Assert-Table
{
    param(
        $Name,

        [string]
        $SchemaName = 'dbo',

        [string]
        $Description,

        [int]
        $DataCompression
    )

    $query = @'
    select 
        t.*, p.data_compression, ex.value MSDescription
    from sys.tables t join 
        sys.partitions p on p.object_id=t.object_id join
        sys.schemas s on t.schema_id = s.schema_id left outer join
        sys.extended_properties ex on ex.major_id = t.object_id and minor_id = 0 and OBJECTPROPERTY(t.object_id, 'IsMsShipped') = 0 and ex.name = 'MS_Description' 
    where
        s.name = '{0}' and t.name = '{1}'
'@ -f $SchemaName,$Name

    $table = Invoke-PstepTestQuery -Query $query -Connection $DatabaseConnection
    Assert-NotNull $table ('table {0} not found' -f $Name) 

    if( $PSBoundParameters.ContainsKey('Description') )
    {
        Assert-Equal $Description $table.MSDescription ('table {0} MS_Description extended property' -f $Name)
    }

    if( $PSBoundParameters.ContainsKey('DataCompression') )
    {
        Assert-Equal $DataCompression $table.data_compression ('table {0} data compression option not set' -f $Name)
    }
}
