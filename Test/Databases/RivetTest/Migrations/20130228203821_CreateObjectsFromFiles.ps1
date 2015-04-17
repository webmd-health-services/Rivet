
function Push-Migration()
{
    Add-StoredProcedure -Name RivetTestSproc -Definition 'as SELECT FirstName, LastName FROM dbo.Person;'
    Add-UserDefinedFunction -Name RivetTestFunction -Definition '(@Number decimal(4,1)) returns decimal(12,3) as begin return(@Number * @Number) end'
    Add-View -Name Migrators -Definition "AS SELECT DISTINCT Name FROM rivet.Migrations"
}

function Pop-Migration()
{
    Remove-View -Name Migrators
    Remove-UserDefinedFunction -Name RivetTestFunction
    Remove-StoredProcedure -Name RivetTestSproc
}
