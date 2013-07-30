function Push-Migration()
{
    Add-Table -Name 'Source' -SchemaName 'rivet' {
        New-Column 'source_id' -Int -NotNull
    }

    Add-Table -Name 'Reference' -SchemaName 'rivet' {
        New-Column 'reference_id' -Int -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id' -SchemaName 'rivet'
    Add-ForeignKey -TableName 'Source' -SchemaName 'rivet' -ColumnName 'source_id' -References 'Reference' -ReferencesSchema 'rivet' -ReferencedColumn 'reference_id'
}

function Pop-Migration()
{
}
