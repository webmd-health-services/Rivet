function Push-Migration()
{
    Add-Table -Name 'PrimaryKey' {
        Int 'id' -NotNull
    }

    
    Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
    Remove-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'

}

function Pop-Migration()
{

}