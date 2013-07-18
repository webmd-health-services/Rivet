

function Push-Migration()
{
    Add-Table -Name 'PrimaryKey' -SchemaName 'pstep' {
        New-Column 'id' -Int -NotNull 
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -SchemaName 'pstep' -ColumnName 'id'

}

function Pop-Migration()
{
    
}
