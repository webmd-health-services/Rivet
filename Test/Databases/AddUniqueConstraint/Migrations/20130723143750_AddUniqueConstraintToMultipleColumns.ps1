function Push-Migration()
{
    Add-Table -Name 'AddUniqueConstraint' {
        New-Column 'UniqueConstraintMe' -Int -NotNull
        New-Column 'UniqueConstraintMe2' -Int -NotNull
        New-Column 'DoNotUniqueConstraintMe' -Int -NotNull
    }

    Add-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe','UniqueConstraintMe2'
}

function Pop-Migration()
{

}
