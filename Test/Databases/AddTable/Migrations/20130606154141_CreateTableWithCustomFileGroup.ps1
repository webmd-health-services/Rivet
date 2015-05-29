
function Push-Migration()
{
    Add-Table 'CustomFileGroup' {
        Int 'id' -Identity
    } -FileGroup '"rivet"' 
}

function Pop-Migration()
{
    Remove-Table 'CustomFileGroup'
}
