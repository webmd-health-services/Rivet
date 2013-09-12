function Push-Migration()
{

    Add-Table -Name 'AddUniqueConstraint' {
        Int 'UniqueConstraintMe' -NotNull
    }

    Add-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe' -On 'ThisShouldFail'
}
function Pop-Migration()
{

}
