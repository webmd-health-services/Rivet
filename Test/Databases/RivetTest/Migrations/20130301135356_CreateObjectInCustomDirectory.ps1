
function Push-Migration()
{
    $miscScriptPath = Join-Path $DBMigrationsRoot '..\MiscellaneousObject.sql'
    Invoke-SqlScript -Path $miscScriptPath
    Invoke-SqlScript -Path ..\ObjectMadeWithRelativePath.sql
}

function Pop-Migration()
{
    Remove-UserDefinedFunction -Name MiscellaneousObject
    Remove-UserDefinedFunction -Name ObjectMadeWithRelativePath
}
