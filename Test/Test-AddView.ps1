function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'NewView' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddView
{
    Invoke-Rivet -Push 'AddNewView'
    
    Assert-View -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
}