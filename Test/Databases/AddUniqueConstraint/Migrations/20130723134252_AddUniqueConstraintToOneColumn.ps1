function Push-Migration()
{
    Add-Table -Name 'AddUniqueConstraint' {
        Int 'UniqueConstraintMe' -NotNull
    }

    Add-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe'
}

function Pop-Migration()
{

}
