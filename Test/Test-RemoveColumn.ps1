
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldRemoveColumns
{
    @'

function Push-Migration()
{

   Invoke-Query -Query @"
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
"@

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
        Decimal decimal -Precision 4 
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
    Remove-Column 'AddColumnNoDefaultsAllNull' 'varchar'  # Testing that parameter names are optional.
    Remove-Column @tableParam -Name 'varcharmax'
    Remove-Column @tableParam -Name 'char'
    Remove-Column @tableParam -Name 'nvarchar'
    Remove-Column @tableParam -Name 'nvarcharmax'
    Remove-Column @tableParam -Name 'nchar'
    Remove-Column @tableParam -Name 'binary'
    Remove-Column @tableParam -Name 'varbinary'
    Remove-Column @tableParam -Name 'varbinarymax'
    Remove-Column @tableParam -Name 'bigint'
    Remove-Column @tableParam -Name 'int'
    Remove-Column @tableParam -Name 'smallint'
    Remove-Column @tableParam -Name 'tinyint'
    Remove-Column @tableParam -Name 'decimal'
    Remove-Column @tableParam -Name 'decimalwithscale'
    Remove-Column @tableParam -Name 'bit'
    Remove-Column @tableParam -Name 'money'
    Remove-Column @tableParam -Name 'smallmoney'
    Remove-Column @tableParam -Name 'float'
    Remove-Column @tableParam -Name 'floatwithprecision'
    Remove-Column @tableParam -Name 'real'
    Remove-Column @tableParam -Name 'date'
    Remove-Column @tableParam -Name 'datetime2'
    Remove-Column @tableParam -Name 'datetimeoffset'
    Remove-Column @tableParam -Name 'smalldatetime'
    Remove-Column @tableParam -Name 'time'
    Remove-Column @tableParam -Name 'xml'
    Remove-Column @tableParam -Name 'sql_variant'
    Remove-Column @tableParam -Name 'uniqueidentifier'
    Remove-Column @tableParam -Name 'hierarchyid'
    Remove-Column @tableParam -Name 'timestamp'
}
'@ | New-Migration -Name 'AddColumnNoDefaultsAllNull'

    Invoke-Rivet -Push 'AddColumnNoDefaultsAllNull'
    
    Assert-True (Test-Table -Name 'AddColumnNoDefaultsAllNull')

    $commonArgs = @{ TableName = 'AddColumnNoDefaultsAllNull' }
    Assert-True (Test-Column -Name 'varchar' @commonArgs)
    Assert-True (Test-Column -Name 'varcharmax' @commonArgs)
    Assert-True (Test-Column -Name 'char' @commonArgs)
    Assert-True (Test-Column -Name 'nvarchar' @commonArgs)
    Assert-True (Test-Column -Name 'nvarcharmax' @commonArgs)
    Assert-True (Test-Column -Name 'nchar' @commonArgs)
    Assert-True (Test-Column -Name 'binary' @commonArgs)
    Assert-True (Test-Column -Name 'varbinary' @commonArgs)
    Assert-True (Test-Column -Name 'varbinarymax' @commonArgs)
    Assert-True (Test-Column -Name 'bigint' @commonArgs)
    Assert-True (Test-Column -Name 'int' @commonArgs)
    Assert-True (Test-Column -Name 'smallint' @commonArgs)
    Assert-True (Test-Column -Name 'tinyint' @commonArgs)
    Assert-True (Test-Column -Name 'decimal' @commonArgs)
    Assert-True (Test-Column -Name 'decimalwithscale' @commonArgs)
    Assert-True (Test-Column -Name 'bit' @commonArgs)
    Assert-True (Test-Column -Name 'money' @commonArgs)
    Assert-True (Test-Column -Name 'smallmoney' @commonArgs)
    Assert-True (Test-Column -Name 'float' @commonArgs)
    Assert-True (Test-Column -Name 'floatwithprecision' @commonArgs)
    Assert-True (Test-Column -Name 'real' @commonArgs)
    Assert-True (Test-Column -Name 'date' @commonArgs)
    Assert-True (Test-Column -Name 'datetime2' @commonArgs)
    Assert-True (Test-Column -Name 'datetimeoffset' @commonArgs)
    Assert-True (Test-Column -Name 'smalldatetime' @commonArgs)
    Assert-True (Test-Column -Name 'time' @commonArgs)
    Assert-True (Test-Column -Name 'xml' @commonArgs)
    Assert-True (Test-Column -Name 'sql_variant' @commonArgs)
    Assert-True (Test-Column -Name 'uniqueidentifier' @commonArgs)
    Assert-True (Test-Column -Name 'hierarchyid' @commonArgs)
    Assert-True (Test-Column -Name 'timestamp' @commonArgs)

    Invoke-Rivet -Pop ([Int]::MaxValue)

    Assert-False (Test-Column -Name 'varchar' @commonArgs)
    Assert-False (Test-Column -Name 'varcharmax' @commonArgs)
    Assert-False (Test-Column -Name 'char' @commonArgs)
    Assert-False (Test-Column -Name 'nvarchar' @commonArgs)
    Assert-False (Test-Column -Name 'nvarcharmax' @commonArgs)
    Assert-False (Test-Column -Name 'nchar' @commonArgs)
    Assert-False (Test-Column -Name 'binary' @commonArgs)
    Assert-False (Test-Column -Name 'varbinary' @commonArgs)
    Assert-False (Test-Column -Name 'varbinarymax' @commonArgs)
    Assert-False (Test-Column -Name 'bigint' @commonArgs)
    Assert-False (Test-Column -Name 'int' @commonArgs)
    Assert-False (Test-Column -Name 'smallint' @commonArgs)
    Assert-False (Test-Column -Name 'tinyint' @commonArgs)
    Assert-False (Test-Column -Name 'decimal' @commonArgs)
    Assert-False (Test-Column -Name 'decimalwithscale' @commonArgs)
    Assert-False (Test-Column -Name 'bit' @commonArgs)
    Assert-False (Test-Column -Name 'money' @commonArgs)
    Assert-False (Test-Column -Name 'smallmoney' @commonArgs)
    Assert-False (Test-Column -Name 'float' @commonArgs)
    Assert-False (Test-Column -Name 'floatwithprecision' @commonArgs)
    Assert-False (Test-Column -Name 'real' @commonArgs)
    Assert-False (Test-Column -Name 'date' @commonArgs)
    Assert-False (Test-Column -Name 'datetime2' @commonArgs)
    Assert-False (Test-Column -Name 'datetimeoffset' @commonArgs)
    Assert-False (Test-Column -Name 'smalldatetime' @commonArgs)
    Assert-False (Test-Column -Name 'time' @commonArgs)
    Assert-False (Test-Column -Name 'xml' @commonArgs)
    Assert-False (Test-Column -Name 'sql_variant' @commonArgs)
    Assert-False (Test-Column -Name 'uniqueidentifier' @commonArgs)
    Assert-False (Test-Column -Name 'hierarchyid' @commonArgs)
    Assert-False (Test-Column -Name 'timestamp' @commonArgs)
}
