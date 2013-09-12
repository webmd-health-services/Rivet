
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
        Char 'IndexMe2' -Size 255 -NotNull
        Int 'DonotIndex' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName "IndexMe","IndexMe2"

}

function Pop-Migration()
{


}
