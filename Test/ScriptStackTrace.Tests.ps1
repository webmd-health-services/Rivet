
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) 

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldDisplayScriptStackTrace
{
    $m = @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Binary 'id' -TestingScriptStackTrace 'BogusString'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'BogusMigration'

    try
    {
        Invoke-RTRivet -Push 'BogusMigration' -ErrorAction SilentlyContinue
        Assert-Error -Last -Regex 'TestingScriptStackTrace'
        Assert-Error -Last -Regex 'STACKTRACE'
    }
    finally
    {
        Remove-Item $m
    }
}
