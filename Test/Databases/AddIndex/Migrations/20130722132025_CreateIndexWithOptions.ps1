function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        New-Column 'IndexMe' -Int -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -Column 'IndexMe' -Unique -Option @('IGNORE_DUP_KEY = ON','ALLOW_ROW_LOCKS = OFF')

}

function Pop-Migration()
{


}
