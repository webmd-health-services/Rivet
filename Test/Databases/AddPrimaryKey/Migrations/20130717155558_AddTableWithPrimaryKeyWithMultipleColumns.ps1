function Push-Migration()
{

    Add-Table -Name 'PrimaryKey' {
        New-Column 'id' -Int -NotNull
        New-Column 'uuid' -UniqueIdentifier -NotNull
        New-Column 'date' -DateTimeOffset -NotNull
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id','uuid','date'

}

function Pop-Migration()
{
}
