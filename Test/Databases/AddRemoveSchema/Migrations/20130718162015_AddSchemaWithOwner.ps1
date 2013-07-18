
function Push-Migration
{
    Invoke-Query 'create user addremoteschema without login'
    Add-Schema -Name 'schemawithowner' -Authorization 'addremoteschema'
}

function Pop-Migration
{
    Remove-Schema -Name 'schemawithowner'
    Invoke-Query 'drop user addremoteschema'
}
