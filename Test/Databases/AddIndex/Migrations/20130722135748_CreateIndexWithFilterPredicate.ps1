function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        New-Column 'IndexMe' -Int -NotNull
        New-Column 'EndDate' -Int 
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -Column 'IndexMe' -Where 'EndDate IS NOT NULL'

}

function Pop-Migration()
{


}
