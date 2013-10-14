
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
    $commonArgs = @{
                        TableName = 'AddColumnDefaultsNotNull'
                   }

    Add-Column -Name varchar -Varchar -Size 20 -NotNull -Default "'varchar'" -Description 'varchar(20) not null' @commonArgs
    Add-Column varcharmax -Varchar -Max -NotNull -Default "'varcharmax'" -Description 'varchar(max) not null' @commonArgs
    Add-Column char -Char 10 -NotNull -Default "'char'" -Description 'char(10) not null' @commonArgs
    Add-Column nchar -Char 35 -Unicode -NotNull -Default "'nchar'" -Description 'nchar(35) not null' @commonArgs
    Add-Column nvarchar -VarChar 30 -Unicode -NotNull -Default "'nvarchar'" -Description 'nvarchar(30) not null' @commonArgs
    Add-Column nvarcharmax -VarChar -Max -Unicode -NotNull -Default "'nvarcharmax'" -Description 'nvarchar(max) not null' @commonArgs
    Add-Column binary -Binary 40 -NotNull -Default 1 -Description 'binary(40) not null' @commonArgs
    Add-Column varbinary -VarBinary 45 -NotNull -Default 2 -Description 'varbinary(45) not null' @commonArgs
    Add-Column varbinarymax -VarBinary -Max -NotNull -Default 3 -Description 'varbinary(max) not null' @commonArgs
    Add-Column bigint -BigInt -NotNull -Default ([int64]::MaxValue) -Description 'bigint not null' @commonArgs
    Add-Column int -Int -NotNull -Default ([int]::MaxValue) -Description 'int not null' @commonArgs
    Add-Column smallint -SmallInt -NotNull -Default ([int16]::MaxValue) -Description 'smallint not null' @commonArgs
    Add-Column tinyint -TinyInt -NotNull -Default ([byte]::MaxValue) -Description 'tinyint not null' @commonArgs
    Add-Column numeric -Numeric 1 -NotNull -Default '1.11' -Description 'numeric(1) not null' @commonArgs
    Add-Column numericwithscale -Numeric 2 2 -NotNull -Default '2.22' -Description 'numeric(2,2) not null' @commonArgs
    Add-Column decimal -Decimal 4 -NotNull -Default '3.33' -Description 'decimal(4) not null' @commonArgs
    Add-Column decimalwithscale -Decimal 5 5 -NotNull -Default '4.44' -Description 'decimal(5,5) not null' @commonArgs
    Add-Column bit -Bit -NotNull -Default '1' -Description 'bit not null' @commonArgs
    Add-Column money -Money -NotNull -Default '6.66' -Description 'money not null' @commonArgs
    Add-Column smallmoney -SmallMoney -NotNull -Default '7.77' -Description 'smallmoney not null' @commonArgs
    Add-Column float -Float -NotNull -Default '8.88' -Description 'float not null' @commonArgs
    Add-Column floatwithprecision -Float 53 -NotNull -Default '9.99' -Description 'float(53) not null' @commonArgs
    Add-Column real -Real -NotNull -Default '10.10' -Description 'real not null' @commonArgs
    Add-Column date -Date -NotNull -Default 'getdate()' -Description 'date not null' @commonArgs
    Add-Column datetime2 -Datetime2 -NotNull -Default 'getdate()' -Description 'datetime2 not null' @commonArgs
    Add-Column datetimeoffset -DateTimeOffset -NotNull -Default 'getdate()' -Description 'datetimeoffset not null' @commonArgs
    Add-Column smalldatetime -smalldatetime -NotNull -Default 'getdate()' -Description 'smalldatetime not null' @commonArgs
    Add-Column time -Time -NotNull -Default 'getdate()' -Description 'time not null' @commonArgs
    Add-Column uniqueidentifier -UniqueIdentifier -NotNull -Default 'newid()' -Description 'uniqueidentifier not null' @commonArgs
    Add-Column xml -Xml -XmlSchemaCollection 'EmptyXsd' -NotNull -Default "'<empty />'" -Description 'xml not null' @commonArgs
    Add-Column sql_variant -SqlVariant -NotNull -Default "'sql_variant'" -Description 'sql_variant not null' @commonArgs
    Add-Column hierarchyid -HierarchyID -NotNull -Default '0x11' -Description 'hierarchyid not null' @commonArgs
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table AddColumnDefaultsNotNull
'@
}
