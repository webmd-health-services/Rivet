

function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'InvokeRivet'
    Start-RivetTest -IgnoredDatabase 'Ignored'
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldHandleNewMigrationForIgnoredDatabase
{
    $Error.Clear()
    ' ' | New-Migration -Name 'Migration' -Database 'Ignored'
    Assert-GreaterThan $Error.Count 0 'no errors'
    Assert-Like $Error[-1].Exception.Message '*ignored*'
}
