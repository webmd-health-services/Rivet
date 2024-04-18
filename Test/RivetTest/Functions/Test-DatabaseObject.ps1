
function Test-DatabaseObject
{
    param(
        [Parameter(Mandatory, ParameterSetName='U')]
        [switch] $Table,

        [Parameter(Mandatory, ParameterSetName='P')]
        [switch] $StoredProcedure,

        [Parameter(Mandatory, ParameterSetName='FN')]
        [switch] $ScalarFunction,

        [Parameter(Mandatory, ParameterSetName='V')]
        [switch] $View,

        [Parameter(Mandatory, ParameterSetName='TA')]
        [switch] $AssemblyTrigger,

        [Parameter(Mandatory, ParameterSetName='TR')]
        [switch] $SQLTrigger,

        [Parameter(Mandatory, ParameterSetName='F')]
        [switch] $ForeignKey,

        [Parameter(Mandatory, Position=1)]
        [String] $Name,

        [Parameter(Position=2)]
        [String] $SchemaName = 'dbo',

        [String] $DatabaseName
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

    $objectCount = Invoke-RivetTestQuery -Query $query -AsScalar -DatabaseName $DatabaseName
    return ($objectCount -eq 1)
}
