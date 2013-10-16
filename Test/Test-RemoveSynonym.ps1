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
    Remove-Synonym -Name 'Buzz'

}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'RemoveSynonym'

    Invoke-Rivet -Push 'RemoveSynonym'
    $Synonyms = @(Get-Synonyms)
    
    Assert-Null $Synonyms

}