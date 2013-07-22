function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        New-Column 'IndexMe' -Int -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -Column 'IndexMe'

    #Remove Index
    Remove-Index -TableName 'AddIndex' -Column 'IndexMe'
}

function Pop-Migration()
{


}
