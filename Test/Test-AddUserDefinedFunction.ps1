function Setup
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'NewUserDefinedFunction' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldAddUserDefinedFunction
{
    Invoke-Rivet -Push 'CreateNewUserDefinedFunction'
    
    Assert-UserDefinedFunction -Name 'squarefunction' -Schema 'dbo' -Definition '(@Number decimal(4,1)) returns decimal(12,3) as begin return(@Number * @Number) end'
}