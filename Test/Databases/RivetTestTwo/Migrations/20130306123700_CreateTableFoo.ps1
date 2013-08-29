function Push-Migration()
{
    Invoke-Query -Query 'create table foo( id int not null )'
}

function Pop-Migration()
{
    Invoke-Query -Query 'drop table foo'
}
