
function Push-Migration()
{
    Set-StoredProcedure -Name RivetTestSproc
    Set-UserDefinedFunction -Name RivetTestFunction
    Set-View -Name Migrators
}

function Pop-Migration()
{
    Remove-View -Name Migrators
    Remove-UserDefinedFunction -Name RivetTestFunction
    Remove-StoredProcedure -Name RivetTestSproc
}
