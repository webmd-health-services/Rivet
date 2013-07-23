function Push-Migration()
{

    Add-Table -Name 'AddIndex' {
        New-Column 'IndexMe' -Int -NotNull
        New-Column 'EndDate' -Int -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Where 'EndDate IS NOT NULL'

}

function Pop-Migration()
{


}
