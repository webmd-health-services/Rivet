
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

    create table DecimalIdentity (
        name varchar(max) not null
    )
'@
    
    Update-Table -Name 'BigIntIdentity' -AddColumn {  BigInt 'bigintidentity' -Identity 1 2 -NotForReplication  }
    Update-Table -Name 'IntIdentity' -AddColumn {  Int 'intidentity' -Identity 3 5 -NotForReplication  }
    Update-Table -Name 'SmallIntIdentity' -AddColumn {  SmallInt 'smallintidentity' -Identity 7 11 -NotForReplication  }
    Update-Table -Name 'TinyIntIdentity' -AddColumn {  TinyInt 'tinyintidentity' -Identity 13 17 -NotForReplication  }
    Update-Table -Name 'DecimalIdentity' -AddColumn {  Decimal 'decimalidentity' -Precision 5 -Identity -Seed 37 -Increment 41 -NotForReplication  }
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table BigIntIdentity
        drop table IntIdentity
        drop table SmallIntIdentity
        drop table TinyIntIdentity
        drop table DecimalIdentity
'@}
