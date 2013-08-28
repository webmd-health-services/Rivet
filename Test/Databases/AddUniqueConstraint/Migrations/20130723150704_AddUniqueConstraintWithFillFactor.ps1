function Push-Migration()
{
    Add-Table -Name 'AddUniqueConstraint' {
        New-Column 'UniqueConstraintMe' -Int -NotNull
        New-Column 'UniqueConstraintMe2' -Int -NotNull
        New-Column 'DoNotUniqueConstraintMe' -Int -NotNull
    }

    Add-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe','UniqueConstraintMe2' -Option @('IGNORE_DUP_KEY = ON','ALLOW_ROW_LOCKS = OFF') -FillFactor 80
}

function Pop-Migration()
{

}
