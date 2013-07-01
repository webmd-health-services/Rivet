
function Push-Migration()
{

    Invoke-Query -Query @'
    create table WithCustomCollation (
        name varchar(max) not null,
    ) 
'@

    Add-Column 'char' -Char 15 -Collation 'Japanese_BIN' -TableName 'WithCustomCollation'
    Add-Column 'nchar' -Char 15 -Unicode -Collation 'Korean_Wansung_BIN' -TableName 'WithCustomCollation'
    Add-Column 'varchar' -VarChar -Collation 'Chinese_Taiwan_Stroke_BIN' -TableName 'WithCustomCollation'
    Add-Column 'nvarchar' -VarChar -Unicode -Collation 'Thai_BIN' -TableName 'WithCustomCollation'
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table WithCustomCollation
'@}
