
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldPreventMigrationFromPopping
{
    $m = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    Stop-Migration -Message 'This migration can''t be reversed. Sorry!'
}
'@ | New-Migration -Name 'AddRowGuidCol'

    Invoke-RTRivet -Push

    $count = Measure-Migration
    try
    {
        Invoke-RTRivet -Pop
        Assert-Error -Last -regex ([regex]::Escape('This migration can''t be reversed. Sorry!'))
        Assert-Equal $count (Measure-Migration)
    }
    finally
    {
        @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@ | Set-Content -Path $m.FullName
    }
}
