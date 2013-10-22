
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
    create table AddColumnNoDefaultsAllNull (
        id int not null
    )
'@

    Update-Table -Name 'AddColumnNoDefaultsAllNull' -AddColumn { 
        VarChar 'varchar' -Size 20 -Description 'varchar(20) null'
        VarChar 'varcharmax' -Max -Description 'varchar(max) null'
        Char 'char' -Size 10 -Description 'char(10) null'
        NChar 'nchar' -Size 35 -Description 'nchar(35) null'
        NVarChar 'nvarchar' -Size 30 -Description 'nvarchar(30) null'
        NVarChar 'nvarcharmax' -Max -Description 'nvarchar(max) null'
        Binary 'binary' -Size 40 -Description 'binary(40) null'
        VarBinary 'varbinary' -Size 45 -Description 'varbinary(45) null'
        VarBinary 'varbinarymax' -Max -Description 'varbinary(max) null'
        BigInt 'bigint' -Description 'bigint null'
        Int 'int' -Description 'int null'
        SmallInt 'smallint' -Description 'smallint null'
        TinyInt 'tinyint' -Description 'tinyint null'
        Decimal 'decimal' -Precision 4 -Description 'decimal(4) null'     
        Decimal 'decimalwithscale' -Precision 5 -Scale 5 -Description 'decimal(5,5) null'
        Bit 'bit' -Description 'bit null'
        Money 'money' -Description 'money null'
        SmallMoney 'smallmoney' -Description 'smallmoney null'
        Float 'float' -Description 'float null'
        Float 'floatwithprecision' -Precision 53 -Description 'float(53) null'
        Real 'real' -Description 'real null'
        Date 'date' -Description 'date null'
        DateTime datetime -Description 'date null'
        DateTime2 'datetime2' -Description 'datetime2 null'
        DateTimeOffset 'datetimeoffset' -Description 'datetimeoffset null'
        SmallDateTime 'smalldatetime' -Description 'smalldatetime null'
        Time 'time' -Description 'time null'
        UniqueIdentifier 'uniqueidentifier' -Description 'uniqueidentifier null'
        Xml 'xml' -XmlSchemaCollection 'EmptyXsd' -Description 'xml null'
        SqlVariant 'sql_variant' -Description 'sql_variant null'
        HierarchyID 'hierarchyid' -Description 'hierarchyid null'
        RowVersion 'timestamp' -Description 'timestamp'
    }
}

function Pop-Migration()
{
    $commonArgs = @{
                        TableName = 'AddColumnNoDefaultsAllNull'
                   }

    Remove-Column -Name varchar @commonArgs
    Remove-Column -Name varcharmax @commonArgs
    Remove-Column char @commonArgs
    Remove-Column nchar @commonArgs
    Remove-Column nvarchar @commonArgs
    Remove-Column nvarcharmax @commonArgs
    Remove-Column binary @commonArgs
    Remove-Column varbinary @commonArgs
    Remove-Column varbinarymax @commonArgs
    Remove-Column bigint @commonArgs
    Remove-Column int @commonArgs
    Remove-Column smallint @commonArgs
    Remove-Column tinyint @commonArgs
    Remove-Column decimal @commonArgs
    Remove-Column decimalwithscale @commonArgs
    Remove-Column bit @commonArgs
    Remove-Column money @commonArgs
    Remove-Column smallmoney @commonArgs
    Remove-Column float @commonArgs
    Remove-Column floatwithprecision @commonArgs
    Remove-Column real @commonArgs
    Remove-Column date @commonArgs
    Remove-Column datetime2 @commonArgs
    Remove-Column datetimeoffset @commonArgs
    Remove-Column smalldatetime @commonArgs
    Remove-Column time @commonArgs
    Remove-Column uniqueidentifier @commonArgs
    Remove-Column xml @commonArgs
    Remove-Column sql_variant @commonArgs
    Remove-Column hierarchyid @commonArgs
    Remove-Column timestamp @commonArgs

   Invoke-Query -Query @'
    drop table AddColumnNoDefaultsAllNull
'@
}
