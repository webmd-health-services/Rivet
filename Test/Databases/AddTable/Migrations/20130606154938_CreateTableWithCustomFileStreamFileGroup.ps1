
function Push-Migration()
{
    Add-Table 'CustomTextImageFileGroup' {
        Int 'id' -Identity
    } -FileStreamFileGroup '"rivet"' 
}

function Pop-Migration()
{
    Remove-Table 'CustomTextImageFileGroup'
}
