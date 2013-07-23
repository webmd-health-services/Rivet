
function Push-Migration()
{
    Add-Table 'CustomTextImageFileGroup' {
        New-Column 'id' -Int -Identity
    } -TextImageFileGroup '"rivet"' 
}

function Pop-Migration()
{
    Invoke-Query 'drop table CustomTextImageFileGroup'
}
