function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        New-Column 'IndexMe' -Int -NotNull
        New-Column 'IndexMe2' -Char 255 -NotNull
        New-Column 'DonotIndex' -Int
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -Column @('IndexMe','IndexMe2')

}

function Pop-Migration()
{


}
