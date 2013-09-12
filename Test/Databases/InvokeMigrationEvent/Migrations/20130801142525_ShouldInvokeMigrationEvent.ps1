function Push-Migration()
{
    Add-Table -Name 'Table1' {
        Int 'columnA' -NotNull
    }
}

function Pop-Migration()
{
}
