
function Start-RivetTest
{
    $tempDir = New-TempDir
    $DatabasesRoot = Join-Path $tempDir (Split-Path -Leaf $DatabasesSourcePath)
    $DatabaseName = '{0}{1}' -f $DatabaseSourceName,(get-date).ToString('yyyyMMddHHmmss')

    Remove-RivetTestDatabase

    Copy-Item -Path $DatabasesSourcePath -Destination $tempDir -Recurse
    Rename-Item -Path (Join-Path $DatabasesRoot $DatabaseSourceName) -NewName $DatabaseName
    $DatabaseRoot = Join-Path $DatabasesRoot $DatabaseName
    
    New-Database

    $DatabaseConnection = New-SqlConnection    
}
