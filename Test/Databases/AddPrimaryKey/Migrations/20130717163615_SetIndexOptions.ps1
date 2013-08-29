function Push-Migration()
{

    Add-Table -Name 'PrimaryKey' {
        New-Column 'id' -Int -NotNull
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -Option 'IGNORE_DUP_KEY = ON','FILLFACTOR = 75'

}

function Pop-Migration()
{
}
