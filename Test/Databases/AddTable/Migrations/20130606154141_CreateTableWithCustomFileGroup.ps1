
function Push-Migration()
{
    Add-Table 'CustomFileGroup' {
        New-Column 'id' -Int -Identity
    } -FileGroup '"pstep"' 
}

function Pop-Migration()
{
    Invoke-Query 'drop table CustomFileGroup'
}
