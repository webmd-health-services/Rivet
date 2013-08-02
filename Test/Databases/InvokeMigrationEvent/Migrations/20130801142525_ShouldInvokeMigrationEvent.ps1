function Push-Migration()
{
    Add-Table -Name 'Table1' {
        New-Column 'columnA' -Int -NotNull
    }
}

function Pop-Migration()
{
}
