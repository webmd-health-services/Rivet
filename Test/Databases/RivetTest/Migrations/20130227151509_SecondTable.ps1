
function Push-Migration()
{
    Add-Table 'secondTable' {
        int 'id' -NotNull
    }
}

function Pop-Migration()
{
    Remove-Table 'secondTable'
}
