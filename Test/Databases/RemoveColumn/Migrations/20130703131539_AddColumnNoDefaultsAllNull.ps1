
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
        New-Column 'id' -Int -Identity 
        New-Column 'varchar' -VarChar 50
        New-Column 'varcharmax' -VarChar
        New-Column 'char' -Char 50
        New-Column 'nvarchar' -VarChar 50 -Unicode
        New-Column 'nvarcharmax' -VarChar -Unicode
        New-Column 'nchar' -Char 50 -Unicode
        New-Column 'binary' -Binary 50
        New-Column 'varbinary' -VarBinary 50
        New-Column 'varbinarymax' -VarBinary
        if( $PSVersionTable.PSVersion -eq ([Version]'2.0') )
        {
            New-Column bigint 'BigInt'
            New-Column int 'Int' 
            New-Column smallint 'SmallInt' 
            New-Column tinyint 'TinyInt' 
            New-Column numeric 'numeric(1)' 
            New-Column decimal 'decimal(4)'
        }
        else
        {
            New-Column bigint -BigInt 
            New-Column int -Int 
            New-Column smallint -SmallInt 
            New-Column tinyint -TinyInt 
            New-Column numeric -Numeric 1 
            New-Column decimal -Decimal 4 
        }
        New-Column 'numericwithscale' -Numeric 5 5
        New-Column 'decimalwithscale' -Decimal 5 5
        New-Column 'bit' -Bit
        New-Column 'money' -Money
        New-Column 'smallmoney' -SmallMoney
        New-Column 'float' -Float
        New-Column 'floatwithprecision' -float 5
        New-Column 'real' -Real
        New-Column 'date' -Date
        New-Column 'datetime' 'datetime'
        New-Column 'datetime2' -Datetime2
        New-Column 'datetimeoffset' -DateTimeOffset
        New-Column 'smalldatetime' 'smalldatetime'
        New-Column 'time' -Time
        New-Column 'xml' -Xml 'EmptyXsd'
        New-Column 'sql_variant' -SqlVariant
        New-Column 'uniqueidentifier' -UniqueIdentifier
        New-Column 'hierarchyid' -HierarchyID
        New-Column 'timestamp' -RowVersion
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
    Remove-Column 'datetime' @tableParam
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
