function Setup
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'NewView'
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldAddView
{
    Invoke-Rivet -Push 'AddNewView'
    
    Assert-View -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
}