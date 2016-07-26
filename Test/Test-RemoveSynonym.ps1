
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRemoveSynonym
{
    @'
function Push-Migration
{
    Add-Synonym -Name 'Buzz' -TargetObjectName 'Fizz'
}

function Pop-Migration
{
    Remove-Synonym -Name 'Buzz'
}
'@ | New-TestMigration -Name 'RemoveSynonym'

    Invoke-RTRivet -Push 'RemoveSynonym'
    Assert-Synonym -Name 'Buzz' -TargetObjectName '[dbo].[Fizz]'

    Invoke-RTRivet -Pop 1

    Assert-Null (Get-Synonym -Name 'Buzz')
}
