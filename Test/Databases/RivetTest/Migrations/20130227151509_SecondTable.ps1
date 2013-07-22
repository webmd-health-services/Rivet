
function Push-Migration()
{
    Invoke-Query -Query @'
    create table secondTable (
        id int not null
    )
'@
}

function Pop-Migration()
{
    Invoke-Query -Query @'
    drop table secondTable
'@
}
