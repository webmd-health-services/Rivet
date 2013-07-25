
function Start-RivetTest
{
    $tempDir = New-TempDir
    $global:DatabasesRoot = Join-Path $tempDir (Split-Path -Leaf $DatabasesSourcePath)
    $global:DatabaseName = '{0}{1}' -f $DatabaseSourceName,(get-date).ToString('yyyyMMddHHmmss')

    Remove-RivetTestDatabase

    Copy-Item -Path $DatabasesSourcePath -Destination $tempDir -Recurse
    Rename-Item -Path (Join-Path $DatabasesRoot $DatabaseSourceName) -NewName $DatabaseName
    $global:DatabaseRoot = Join-Path $DatabasesRoot $DatabaseName
    
    New-Database

    $global:DatabaseConnection = New-SqlConnection 

    $global:ConfigFilePath = Join-Path -Path $tempDir -ChildPath 'rivet.json'

    @"
{
    SqlServerName: '$($Server.Replace('\', '\\'))',
    DatabasesRoot: '$($DatabasesRoot.Replace('\','\\'))'
}
"@ | Set-Content -Path $ConfigFilePath
}
