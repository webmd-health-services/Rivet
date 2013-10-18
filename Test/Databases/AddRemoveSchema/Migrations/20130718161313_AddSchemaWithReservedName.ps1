
function Push-Migration()
{
    Add-Schema -Name 'alter'
}

function Pop-Migration()
{
    Remove-Schema -Name 'alter'
}
