
function Push-Migration()
{
    Invoke-Query -Query @'
create xml schema collection EmptyXsd as 
N'
<xsd:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions" 
   xmlns          ="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions" 
   elementFormDefault="qualified" 
   attributeFormDefault="unqualified"
   xmlns:xsd="http://www.w3.org/2001/XMLSchema" >

	<xsd:element  name="root" />

</xsd:schema>
';
'@

    Invoke-Query -Query @'
    create table AddColumnDefaultsNotNull (
        id int not null
    )
'@

    Update-Table -Name 'AddColumnDefaultsNotNull' -AddColumn { 
        VarChar 'varchar' -Size 20 -NotNull -Default "'varchar'" -Description 'varchar(20) not null'
        VarChar 'varcharmax' -Max -NotNull -Default "'varcharmax'" -Description 'varchar(max) not null'
        Char 'char' -Size 10 -NotNull -Default "'char'" -Description 'char(10) not null'
        NChar 'nchar' -Size 35 -NotNull -Default "'nchar'" -Description 'nchar(35) not null'
        NVarChar 'nvarchar' -Size 30 -NotNull -Default "'nvarchar'" -Description 'nvarchar(30) not null'
        NVarChar 'nvarcharmax' -Max -NotNull -Default "'nvarcharmax'" -Description 'nvarchar(max) not null'
        Binary 'binary' -Size 40 -NotNull -Default 1 -Description 'binary(40) not null'
        VarBinary 'varbinary' -Size 45 -NotNull -Default 2 -Description 'varbinary(45) not null'
        VarBinary 'varbinarymax' -Max -NotNull -Default 3 -Description 'varbinary(max) not null'
        BigInt 'bigint' -NotNull -Default ([int64]::MaxValue) -Description 'bigint not null'
        Int 'int' -NotNull -Default ([int]::MaxValue) -Description 'int not null'
        SmallInt 'smallint' -NotNull -Default ([int16]::MaxValue) -Description 'smallint not null'
        TinyInt 'tinyint' -NotNull -Default ([byte]::MaxValue) -Description 'tinyint not null'
        Decimal 'decimal' -Precision 4 -NotNull -Default '3.33' -Description 'decimal(4) not null'     
        Decimal 'decimalwithscale' -Precision 5 -Scale 5 -NotNull -Default '4.44' -Description 'decimal(5,5) not null'
        Bit 'bit' -NotNull -Default '1' -Description 'bit not null'
        Money 'money' -NotNull -Default '6.66' -Description 'money not null'
        SmallMoney 'smallmoney' -NotNull -Default '7.77' -Description 'smallmoney not null'
        Float 'float' -NotNull -Default '8.88' -Description 'float not null'
        Float 'floatwithprecision' -Precision 53 -NotNull -Default '9.99' -Description 'float(53) not null'
        Real 'real' -NotNull -Default '10.10' -Description 'real not null'
        Date 'date' -NotNull -Default 'getdate()' -Description 'date not null'
        DateTime2 'datetime2' -NotNull -Default 'getdate()' -Description 'datetime2 not null'
        DateTimeOffset 'datetimeoffset' -NotNull -Default 'getdate()' -Description 'datetimeoffset not null'
        SmallDateTime 'smalldatetime' -NotNull -Default 'getdate()' -Description 'smalldatetime not null'
        Time 'time' -NotNull -Default 'getdate()' -Description 'time not null'
        UniqueIdentifier 'uniqueidentifier' -NotNull -Default 'newid()' -Description 'uniqueidentifier not null'
        Xml 'xml' -XmlSchemaCollection 'EmptyXsd' -NotNull -Default "'<empty />'" -Description 'xml not null'
        SqlVariant 'sql_variant' -NotNull -Default "'sql_variant'" -Description 'sql_variant not null'
        HierarchyID 'hierarchyid' -NotNull -Default '0x11' -Description 'hierarchyid not null'
    }
}


function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table AddColumnDefaultsNotNull
'@
}
