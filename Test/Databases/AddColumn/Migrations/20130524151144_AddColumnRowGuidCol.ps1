
function Push-Migration()
{
    Invoke-Query -Query @'
    create table WithRowGuidCol (
        name varchar(max) not null
    )
'@
    
    Update-Table -Name 'WithRowGuidCol' -AddColumn {  UniqueIdentifier 'uniqueidentiferasrowguidcol' -RowGuidCol  }
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table WithRowGuidCol
'@}
