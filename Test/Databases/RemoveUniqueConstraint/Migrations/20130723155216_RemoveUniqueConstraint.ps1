function Push-Migration()
{
    Add-Table -Name 'RemoveUniqueConstraint' {
        Int 'RemoveMyUniqueConstraint' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-UniqueConstraint -TableName 'RemoveUniqueConstraint' -ColumnName 'RemoveMyUniqueConstraint'

    #Remove Index
    Remove-UniqueConstraint -TableName 'RemoveUniqueConstraint' -ColumnName 'RemoveMyUniqueConstraint'
}

function Pop-Migration()
{
}
