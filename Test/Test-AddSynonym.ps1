
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldAddSynonym
{
    @'
function Push-Migration
{
    Add-Schema 'fiz'
    Add-Schema 'baz'
    Add-Synonym -Name 'Buzz' -TargetObjectName 'Fizz'
    Add-Synonym -SchemaName 'fiz' -Name 'Buzz' -TargetSchemaName 'baz' -TargetObjectName 'Buzz'
    Add-Synonym -Name 'Buzzed' -TargetDatabaseName 'Fizzy' -TargetObjectName 'Buzz'
}

function Pop-Migration
{
    Remove-Synonym 'Buzzed'
    Remove-Synonym 'Buzz' -SchemaName 'fiz'
    Remove-Synonym 'Buzz'
    Remove-Schema 'baz'
    Remove-Schema 'fiz'
}

'@ | New-Migration -Name 'AddSynonym'

    Invoke-Rivet -Push 'AddSynonym'
    Assert-Synonym -Name 'Buzz' -TargetObjectName '[dbo].[Fizz]'
    Assert-Synonym -SchemaName 'fiz' -Name 'Buzz' -TargetObjectName '[baz].[Buzz]'
    Assert-Synonym -Name 'Buzzed' -TargetObjectName '[Fizzy].[dbo].[Buzz]'
}