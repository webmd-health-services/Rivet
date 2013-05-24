
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
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        $Name
    )
    
    
    $query = "select count(*) from sys.objects where type = '{0}' and name = '{1}'" -f $pscmdlet.ParameterSetName,$Name
    $objectCount = Invoke-PstepTestQuery -Query $query -Connection $DatabaseConnection -AsScalar
    return ($objectCount -eq 1)
}
