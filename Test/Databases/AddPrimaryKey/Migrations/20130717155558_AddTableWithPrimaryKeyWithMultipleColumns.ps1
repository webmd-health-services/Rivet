function Push-Migration()
{

    Add-Table -Name 'PrimaryKey' {
        Int 'id' -NotNull
        UniqueIdentifier 'uuid' -NotNull
        DateTimeOffset 'date' -NotNull
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id','uuid','date'

}

function Pop-Migration()
{
}
