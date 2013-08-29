function Push-Migration()
{
    Add-Table -Name 'Source' {
        New-Column 's_id_1' -Int -NotNull
        New-Column 's_id_2' -Int -NotNull
    }

    Add-Table -Name 'Reference' {
        New-Column 'r_id_1' -Int -NotNull
        New-Column 'r_id_2' -Int -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'r_id_1','r_id_2'
    Add-ForeignKey -TableName 'Source' -ColumnName 's_id_1','s_id_2' -References 'Reference' -ReferencedColumn 'r_id_1','r_id_2'
}

function Pop-Migration()
{
}
