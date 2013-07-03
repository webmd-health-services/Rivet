
function Push-Migration()
{

    Invoke-Query -Query @'
    create table WithVarBinaryFileStream (
        name varchar(max) not null,
        firstvarbinary varbinary(max) filestream,
        [rowguidcol] uniqueidentifier not null rowguidcol primary key
    ) filestream_on "default"
'@

    Add-Column 'filestreamvarbinary' -VarBinary -FileStream -TableName 'WithVarBinaryFileStream'
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table WithVarBinaryFileStream
'@}
