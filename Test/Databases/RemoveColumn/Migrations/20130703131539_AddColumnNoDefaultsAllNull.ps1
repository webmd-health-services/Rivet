
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

    Add-Table AddColumnNoDefaultsAllNull {
        Int 'id' -Identity 
        VarChar 'varchar' -Size 50
        VarChar 'varcharmax' -Max
        Char 'char' -Size 50
        NVarChar 'nvarchar' -Size 50
        NVarChar 'nvarcharmax' -Max
        NChar 'nchar' -Size 50
        Binary 'binary' -Size 50
        VarBinary 'varbinary' -Size 50
        VarBinary 'varbinarymax' -Max
        BigInt bigint 
        Int int 
        SmallInt smallint 
        TinyInt tinyint 
        Numeric numeric -Precision 1 
        Decimal decimal -Precision 4 
        Numeric 'numericwithscale' -Precision 5 -Scale 5
        Decimal 'decimalwithscale' -Precision 5 -Scale 5
        Bit 'bit' 
        Money 'money' 
        SmallMoney 'smallmoney' 
        Float 'float' 
        Float 'floatwithprecision' -Precision 5
        Real 'real' 
        Date 'date' 
        Datetime2 'datetime2' 
        DateTimeOffset 'datetimeoffset' 
        SmallDateTime 'smalldatetime' 
        Time 'time' 
        Xml 'xml' -XmlSchemaCollection 'EmptyXsd'
        SqlVariant 'sql_variant' 
        UniqueIdentifier 'uniqueidentifier' 
        HierarchyID 'hierarchyid' 
        RowVersion 'timestamp' 
    }
}

function Pop-Migration()
{
    $tableParam = @{ TableName = 'AddColumnNoDefaultsAllNull' }
    Remove-Column 'varchar' @tableParam
    Remove-Column 'varcharmax' @tableParam
    Remove-Column 'char' @tableParam
    Remove-Column 'nvarchar' @tableParam
    Remove-Column 'nvarcharmax' @tableParam
    Remove-Column 'nchar' @tableParam
    Remove-Column 'binary' @tableParam
    Remove-Column 'varbinary' @tableParam
    Remove-Column 'varbinarymax' @tableParam
    Remove-Column 'bigint' @tableParam
    Remove-Column 'int' @tableParam
    Remove-Column 'smallint' @tableParam
    Remove-Column 'tinyint' @tableParam
    Remove-Column 'numeric' @tableParam
    Remove-Column 'numericwithscale' @tableParam
    Remove-Column 'decimal' @tableParam
    Remove-Column 'decimalwithscale' @tableParam
    Remove-Column 'bit' @tableParam
    Remove-Column 'money' @tableParam
    Remove-Column 'smallmoney' @tableParam
    Remove-Column 'float' @tableParam
    Remove-Column 'floatwithprecision' @tableParam
    Remove-Column 'real' @tableParam
    Remove-Column 'date' @tableParam
    Remove-Column 'datetime2' @tableParam
    Remove-Column 'datetimeoffset' @tableParam
    Remove-Column 'smalldatetime' @tableParam
    Remove-Column 'time' @tableParam
    Remove-Column 'xml' @tableParam
    Remove-Column 'sql_variant' @tableParam
    Remove-Column 'uniqueidentifier' @tableParam
    Remove-Column 'hierarchyid' @tableParam
    Remove-Column 'timestamp' @tableParam
}
