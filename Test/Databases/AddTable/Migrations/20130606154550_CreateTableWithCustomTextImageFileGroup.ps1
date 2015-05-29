
function Push-Migration()
{
    Add-Table 'CustomTextImageFileGroup' {
        Int 'id' -Identity
    } -TextImageFileGroup '"rivet"' 
}

function Pop-Migration()
{
    Remove-Table 'CustomTextImageFileGroup'
}
