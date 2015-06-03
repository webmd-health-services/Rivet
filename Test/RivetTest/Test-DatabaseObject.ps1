
function Test-DatabaseObject
{
    param(
        [Parameter(Mandatory=$true,ParameterSetName='U')]
        [Switch]
        $Table,
        
        [Parameter(Mandatory=$true,ParameterSetName='P')]
        [Switch]
        $StoredProcedure,
        
        [Parameter(Mandatory=$true,ParameterSetName='FN')]
        [Switch]
        $ScalarFunction,
        
        [Parameter(Mandatory=$true,ParameterSetName='V')]
        [Switch]
        $View,

        [Parameter(Mandatory=$true,ParameterSetName='TA')]
        [Switch]
        $AssemblyTrigger,

        [Parameter(Mandatory=$true,ParameterSetName='TR')]
        [Switch]
        $SQLTrigger,

        [Parameter(Mandatory=$true,ParameterSetName='F')]
        [Switch]
        $ForeignKey,
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        $Name,
        
        [Parameter(Position=2)]
        [string]
        $SchemaName = 'dbo'
    )
    
    
    #$query = "select count(*) from sys.objects where type = '{0}' and name = '{1}'"
    $query = @'
    select 
        count(*) 
    from 
        sys.objects o join 
        sys.schemas s on o.schema_id = s.schema_id 
    where 
        o.type = '{0}' and o.name = '{1}' and s.name = '{2}'
'@ -f $pscmdlet.ParameterSetName,$Name,$SchemaName

    $objectCount = Invoke-RivetTestQuery -Query $query -AsScalar
    return ($objectCount -eq 1)
}
