function Push-Migration()
{
    Add-Table -Name 'Source' {
        Int 'source_id' -NotNull
    }

    Add-Table -Name 'Reference' {
        Int 'reference_id' -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
    Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id' -OnDelete 'CASCADE' -OnUpdate 'CASCADE' -NotForReplication
    Remove-ForeignKey -TableName 'Source' -Name 'FK_Source_Reference'
}

function Pop-Migration()
{

}
