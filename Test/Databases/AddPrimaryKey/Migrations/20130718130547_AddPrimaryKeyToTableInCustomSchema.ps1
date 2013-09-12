function Push-Migration()
{
    Add-Table -Name 'PrimaryKey' -SchemaName 'rivet' {
        Int 'id' -NotNull 
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -SchemaName 'rivet' -ColumnName 'id'

}

function Pop-Migration()
{
    
}
