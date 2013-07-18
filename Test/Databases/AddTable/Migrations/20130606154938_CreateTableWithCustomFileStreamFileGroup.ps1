
function Push-Migration()
{
    Add-Table 'CustomTextImageFileGroup' {
        New-Column 'id' -Int -Identity
    } -FileStreamFileGroup '"rivet"' 
}

function Pop-Migration()
{
    Invoke-Query 'drop table CustomTextImageFileGroup'
}
