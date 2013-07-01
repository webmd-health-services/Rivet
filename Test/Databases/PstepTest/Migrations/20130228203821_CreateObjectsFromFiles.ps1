
function Push-Migration()
{
    Set-StoredProcedure -Name PstepTestSproc
    Set-UserDefinedFunction -Name PstepTestFunction
    Set-View -Name Migrators
}

function Pop-Migration()
{
    Remove-View -Name Migrators
    Remove-UserDefinedFunction -Name PstepTestFunction
    Remove-StoredProcedure -Name PstepTestSproc
}
