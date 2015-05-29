function Push-Migration()
{
    Add-Table 'foo' -Column {
        int 'id' -NotNull
    }
}

function Pop-Migration()
{
    Remove-Table 'foo'
}
