
function Push-Migration()
{
    Add-Table 'FourthTable' -Column {
        int 'id' -NotNull
    }
}

function Pop-Migration()
{
    Remove-Table 'FourthTable'
}
