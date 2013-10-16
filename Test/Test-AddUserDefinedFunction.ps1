function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'NewUserDefinedFunction' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddUserDefinedFunction
{
    Invoke-Rivet -Push 'CreateNewUserDefinedFunction'
    
    Assert-UserDefinedFunction -Name 'squarefunction' -Schema 'dbo' -Definition '(@Number decimal(4,1)) returns decimal(12,3) as begin return(@Number * @Number) end'
}