function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddSynonym' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddSynonym
{
    @'
function Push-Migration
{
    Invoke-Query 'create schema fiz'
    Invoke-Query 'create schema baz'
    Add-Synonym -Name 'Buzz' -TargetObjectName 'Fizz'
    Add-Synonym -SchemaName 'fiz' -Name 'Buzz' -TargetSchemaName 'baz' -TargetObjectName 'Buzz'
    Add-Synonym -Name 'Buzzed' -TargetDatabaseName 'Fizzy' -TargetObjectName 'Buzz'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'AddSynonym'

    Invoke-Rivet -Push 'AddSynonym'
    $Synonyms = @(Get-Synonyms)

    Assert-Equal "SN" $Synonyms[0].type
    Assert-Equal "Buzz" $Synonyms[0].name
    Assert-Equal "[dbo].[Fizz]" $Synonyms[0].base_object_name

    Assert-Equal "SN" $Synonyms[1].type
    Assert-Equal "Buzz" $Synonyms[1].name
    Assert-Equal "[baz].[Buzz]" $Synonyms[1].base_object_name

    Assert-Equal "SN" $Synonyms[2].type
    Assert-Equal "Buzzed" $Synonyms[2].name
    Assert-Equal "[Fizzy].[dbo].[Buzz]" $Synonyms[2].base_object_name

}