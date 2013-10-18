
function Push-Migration()
{
    Add-Schema -Name 'rivetaddremoveschema'
}

function Pop-Migration()
{
    Remove-Schema -Name 'rivetaddremoveschema'
}
