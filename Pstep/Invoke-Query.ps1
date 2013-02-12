
function Invoke-Query
{
    [CmdletBinding()]
    param(
        $Query,
        
        $Database = $Database
    )
    
    Write-Verbose ('[{0}.{1}] {2}' -f $SqlServerName,$Database,$Query)
    Invoke-SqlCmd -ServerInstance $SqlServerName -Database $Database -Query $Query
}
