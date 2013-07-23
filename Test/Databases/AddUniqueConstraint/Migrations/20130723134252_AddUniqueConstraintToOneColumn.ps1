function Push-Migration()
{
    Add-Table -Name 'AddUniqueConstraint' {
        New-Column 'UniqueConstraintMe' -Int -NotNull
    }

    Add-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe'
}

function Pop-Migration()
{

}
