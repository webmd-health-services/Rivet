function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'NewStoredProcedure' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateNewStoredProcedure
{
    Invoke-Rivet -Push 'CreateNewStoredProcedure'

    Assert-StoredProcedure -Name 'TestStoredProcedure' -Definition 'SELECT FirstName, LastName FROM dbo.Person;' -SchemaName 'dbo'
}