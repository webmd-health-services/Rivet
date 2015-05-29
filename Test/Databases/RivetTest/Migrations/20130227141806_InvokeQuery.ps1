
function Push-Migration()
{
    Add-Table 'InvokeQuery' {
        int 'id' -NotNull
    }
}

function Pop-Migration()
{
    Remove-Table 'InvokeQuery'
}
