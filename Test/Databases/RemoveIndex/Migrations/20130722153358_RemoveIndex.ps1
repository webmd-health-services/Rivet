function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe'

    #Remove Index
    Remove-Index -TableName 'AddIndex' -ColumnName 'IndexMe'
}

function Pop-Migration()
{


}
