
function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RemoveSynonym' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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
'@ | New-Migration -Name 'RemoveSynonym'

    Invoke-Rivet -Push 'RemoveSynonym'
    Assert-Synonym -Name 'Buzz' -TargetObjectName '[dbo].[Fizz]'

    Invoke-Rivet -Pop 1

    Assert-Null (Get-Synonym -Name 'Buzz')
}