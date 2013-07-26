
function Start-RivetTest
{
    [CmdletBinding()]
    param(
    )
    
    Set-StrictMode -Version Latest
    
    $tempDir = New-TempDir
    $global:RTDatabasesRoot = Join-Path $tempDir (Split-Path -Leaf $RTDatabasesSourcePath)
    $global:RTDatabaseName = '{0}{1}' -f $RTDatabaseSourceName,(get-date).ToString('yyyyMMddHHmmss')

    Remove-RivetTestDatabase

    Copy-Item -Path $RTDatabasesSourcePath -Destination $tempDir -Recurse
    Rename-Item -Path (Join-Path $RTDatabasesRoot $RTDatabaseSourceName) -NewName $RTDatabaseName
    $global:RTDatabaseRoot = Join-Path $RTDatabasesRoot $RTDatabaseName
    
    New-Database

    $global:RTDatabaseConnection = New-SqlConnection 

    $global:RTConfigFilePath = Join-Path -Path $tempDir -ChildPath 'rivet.json'

    @"
{
    SqlServerName: '$($RTServer.Replace('\', '\\'))',
    DatabasesRoot: '$($RTDatabasesRoot.Replace('\','\\'))'
}
"@ | Set-Content -Path $RTConfigFilePath
}
