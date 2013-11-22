
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
    create table WithSparseColumns (
        name varchar(max) not null,
    ) 
'@

    Update-Table -Name 'WithSparseColumns' -AddColumn { 
        VarChar 'varchar' -Size 20 -Sparse -Description 'varchar(20) sparse'
        VarChar 'varcharmax' -Max -Sparse -Description 'varchar(max) sparse'
        Char 'char' -Size 10 -Sparse -Description 'char(10) sparse'
        NChar 'nchar' -Size 35 -Sparse -Description 'nchar(35) sparse'
        NVarChar 'nvarchar' -Size 30 -Sparse -Description 'nvarchar(30) sparse'
        NVarChar 'nvarcharmax' -Max -Sparse -Description 'nvarchar(max) sparse'
        Binary 'binary' -Size 40 -Sparse -Description 'binary(40) sparse'
        VarBinary 'varbinary' -Size 45 -Sparse -Description 'varbinary(45) sparse'
        VarBinary 'varbinarymax' -Max -Sparse -Description 'varbinary(max) sparse'
        BigInt 'bigint' -Sparse -Description 'bigint sparse'
        Int 'int' -Sparse -Description 'int sparse'
        SmallInt 'smallint' -Sparse -Description 'smallint sparse'
        TinyInt 'tinyint' -Sparse -Description 'tinyint sparse'
        Decimal 'decimal' -Precision 4 -Sparse -Description 'decimal(4) sparse'     
        Decimal 'decimalwithscale' -Precision 5 -Scale 5 -Sparse -Description 'decimal(5,5) sparse'
        Bit 'bit' -Sparse -Description 'bit sparse'
        Money 'money' -Sparse -Description 'money sparse'
        SmallMoney 'smallmoney' -Sparse -Description 'smallmoney sparse'
        Float 'float' -Sparse -Description 'float sparse'
        Float 'floatwithprecision' -Precision 53 -Sparse -Description 'float(53) sparse'
        Real 'real' -Sparse -Description 'real sparse'
        Date 'date' -Sparse -Description 'date sparse'
        DateTime datetime -Sparse -Description 'date sparse'
        DateTime2 'datetime2' -Sparse -Description 'datetime2 sparse'
        DateTimeOffset 'datetimeoffset' -Sparse -Description 'datetimeoffset sparse'
        SmallDateTime 'smalldatetime' -Sparse -Description 'smalldatetime sparse'
        Time 'time' -Sparse -Description 'time sparse'
        UniqueIdentifier 'uniqueidentifier' -Sparse -Description 'uniqueidentifier sparse'
        Xml 'xml' -XmlSchemaCollection 'EmptyXsd' -Sparse -Description 'xml sparse'
        SqlVariant 'sql_variant' -Sparse -Description 'sql_variant sparse'
        HierarchyID 'hierarchyid' -Sparse -Description 'hierarchyid sparse'
    }
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table WithSparseColumns
'@}
