function Push-Migration()
{
    Add-Table -Name 'AddUniqueConstraint' {
        Int 'UniqueConstraintMe' -NotNull
        Int 'UniqueConstraintMe2' -NotNull
        Int 'DoNotUniqueConstraintMe' -NotNull
    }

    Add-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe','UniqueConstraintMe2'
}

function Pop-Migration()
{

}
