
function Push-Migration()
{
    $miscScriptPath = Join-Path $DBScriptRoot MiscellaneousObject.sql
    Invoke-SqlScript -Path $miscScriptPath
}

function Pop-Migration()
{
    Remove-UserDefinedFunction -Name MiscellaneousObject
}
