
function Push-Migration()
{
    Add-Table 'CustomFileGroup' {
        New-Column 'id' -Int -Identity
    } -FileGroup '"rivet"' 
}

function Pop-Migration()
{
    Invoke-Query 'drop table CustomFileGroup'
}
