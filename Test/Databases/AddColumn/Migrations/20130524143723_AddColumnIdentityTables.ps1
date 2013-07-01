
function Push-Migration()
{
    Invoke-Query -Query @'
    create table BigIntIdentity (
        name varchar(max) not null
    )

    create table IntIdentity (
        name varchar(max) not null
    )

    create table SmallIntIdentity (
        name varchar(max) not null
    )

    create table TinyIntIdentity (
        name varchar(max) not null
    )

    create table NumericIdentity (
        name varchar(max) not null
    )

    create table DecimalIdentity (
        name varchar(max) not null
    )
'@

    Add-Column 'bigintidentity' -BigInt -Identity 1 2 -TableName 'BigIntIdentity'
    Add-Column 'intidentity' -Int -Identity 3 5 -TableName 'IntIdentity'
    Add-Column 'smallintidentity' -SmallInt -Identity 7 11 -TableName 'SmallIntIdentity'
    Add-Column 'tinyintidentity' -TinyInt -Identity 13 17  -TableName 'TinyIntIdentity'
    Add-Column 'numericidentity' -Numeric 5 -Identity 23 29 -TableName 'NumericIdentity'
    Add-Column 'decimalidentity' -Decimal 5 -Identity 37 41 -TableName 'DecimalIdentity'
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table BigIntIdentity
        drop table IntIdentity
        drop table SmallIntIdentity
        drop table TinyIntIdentity
        drop table NumericIdentity
        drop table DecimalIdentity
'@}
