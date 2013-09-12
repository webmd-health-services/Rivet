function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
        Int 'EndDate' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -FileStreamOn 'ThisShouldFail'

}

function Pop-Migration()
{


}
