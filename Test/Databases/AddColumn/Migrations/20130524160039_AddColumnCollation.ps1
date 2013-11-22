
function Push-Migration()
{
    Invoke-Query -Query @'
    create table WithCustomCollation (
        name varchar(max) not null,
    ) 
'@
    Update-Table -Name 'WithCustomCollation' -AddColumn {
        Char 'char' 15 -Collation 'Japanese_BIN'
        NChar 'nchar' 15 -Collation 'Korean_Wansung_BIN'
        VarChar 'varchar' -Max -Collation 'Chinese_Taiwan_Stroke_BIN'
        NVarChar 'nvarchar' -Max -Collation 'Thai_BIN'
    }
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table WithCustomCollation
'@}
