function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'ScriptStackTrace' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldDisplayScriptStackTrace
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Binary 'id' -TestingScriptStackTrace 'BogusString'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'BogusMigration'

    Invoke-Rivet -Push 'BogusMigration' -ErrorAction SilentlyContinue -ErrorVariable rivetError
    Assert-True ($rivetError.Count -gt 0)
    Assert-Like $rivetError[6] 'TestingScriptStackTrace'
    Assert-Like $rivetError[6] 'STACKTRACE'

}