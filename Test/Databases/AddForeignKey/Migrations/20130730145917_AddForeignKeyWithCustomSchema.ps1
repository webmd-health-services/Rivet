function Push-Migration()
{
    Add-Table -Name 'Source' -SchemaName 'rivet' {
        Int 'source_id' -NotNull
    }

    Add-Table -Name 'Reference' -SchemaName 'rivet' {
        Int 'reference_id' -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id' -SchemaName 'rivet'
    Add-ForeignKey -TableName 'Source' -SchemaName 'rivet' -ColumnName 'source_id' -References 'Reference' -ReferencesSchema 'rivet' -ReferencedColumn 'reference_id'
}

function Pop-Migration()
{
}
