function Setup
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'NewStoredProcedure' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldCreateNewStoredProcedure
{
    Invoke-Rivet -Push 'CreateNewStoredProcedure'

    Assert-StoredProcedure -Name 'TestStoredProcedure' -Definition 'as SELECT FirstName, LastName FROM dbo.Person;' -SchemaName 'dbo'
}