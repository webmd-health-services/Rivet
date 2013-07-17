
function Push-Migration()
{
    Invoke-Query -Query @'
    create table InvokeQuery (
        id int not null
    )
'@
}

function Pop-Migration()
{
    Invoke-Query -Query @'
    drop table InvokeQuery
'@
}
