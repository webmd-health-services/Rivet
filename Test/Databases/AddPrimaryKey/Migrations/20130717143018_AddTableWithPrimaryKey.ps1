
function Push-Migration()
{
    Add-Table -Name 'PrimaryKey' {
        New-Column 'id' -Int -NotNull
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
}

function Pop-Migration()
{
    #Remove-PrimaryKey -TableName 'PrimaryKey'
}

    