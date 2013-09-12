function Push-Migration()
{
    Add-Table -Name 'Source' {
        Int 's_id_1' -NotNull
        Int 's_id_2' -NotNull
    }

    Add-Table -Name 'Reference' {
        Int 'r_id_1' -NotNull
        Int 'r_id_2' -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'r_id_1','r_id_2'
    Add-ForeignKey -TableName 'Source' -ColumnName 's_id_1','s_id_2' -References 'Reference' -ReferencedColumn 'r_id_1','r_id_2'
}

function Pop-Migration()
{
}
