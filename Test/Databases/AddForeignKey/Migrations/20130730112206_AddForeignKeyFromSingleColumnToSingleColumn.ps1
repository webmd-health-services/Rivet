function Push-Migration()
{
    Add-Table -Name 'Source' {
        New-Column 'source_id' -Int -NotNull
    }

    Add-Table -Name 'Reference' {
        New-Column 'reference_id' -Int -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
    Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id'
}

function Pop-Migration()
{
}
