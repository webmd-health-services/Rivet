
function Push-Migration()
{
    Invoke-Query -Query @'
    create table WithVarBinaryFileStream (
        name varchar(max) not null,
        firstvarbinary varbinary(max) filestream,
        [rowguidcol] uniqueidentifier not null rowguidcol primary key
    ) filestream_on "default"
'@
    Update-Table -Name 'WithVarBinaryFileStream' {  VarBinary 'filestreamvarbinary' -FileStream }
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table WithVarBinaryFileStream
'@}
