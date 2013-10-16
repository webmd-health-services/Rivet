
function Push-Migration()
{
    Invoke-Query -Query @'
    create table WithRowGuidCol (
        name varchar(max) not null
    )
'@

    Add-Column 'uniqueidentiferasrowguidcol' -UniqueIdentifier -RowGuidCol -TableName 'WithRowGuidCol'
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table WithRowGuidCol
'@}
