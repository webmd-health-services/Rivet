& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Setup
{
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldAddUserDefinedFunction
{
    @'
function Push-Migration
{
    Add-UserDefinedFunction -Name 'squarefunction' -Schema 'dbo' -Definition '(@Number decimal(4,1)) returns decimal(12,3) as begin return(@Number * @Number) end'
}

function Pop-Migration
{
    Remove-UserDefinedFunction -Name 'squarefunction'
}
'@ | New-Migration -Name 'CreateNewUserDefinedFunction'
    Invoke-Rivet -Push 'CreateNewUserDefinedFunction'
    
    Assert-UserDefinedFunction -Name 'squarefunction' -Schema 'dbo' -Definition '(@Number decimal(4,1)) returns decimal(12,3) as begin return(@Number * @Number) end'
}