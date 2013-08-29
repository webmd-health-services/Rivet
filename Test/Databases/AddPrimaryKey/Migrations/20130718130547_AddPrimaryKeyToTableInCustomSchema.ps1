function Push-Migration()
{
    Add-Table -Name 'PrimaryKey' -SchemaName 'rivet' {
        New-Column 'id' -Int -NotNull 
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -SchemaName 'rivet' -ColumnName 'id'

}

function Pop-Migration()
{
    
}
