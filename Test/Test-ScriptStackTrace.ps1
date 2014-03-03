function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'ScriptStackTrace' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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