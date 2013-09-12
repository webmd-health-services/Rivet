function Push-Migration()
{
    Add-Table -Name 'AddUniqueConstraint' {
        Int 'UniqueConstraintMe' -NotNull
        Int 'UniqueConstraintMe2' -NotNull
        Int 'DoNotUniqueConstraintMe' -NotNull
    }

    Add-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe','UniqueConstraintMe2' -Option @('IGNORE_DUP_KEY = ON','ALLOW_ROW_LOCKS = OFF')
}

function Pop-Migration()
{

}
