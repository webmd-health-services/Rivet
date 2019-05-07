
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

Describe 'Columns' {

    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should add nullable columns no defaults' {
        @"
function Push-Migration
{
    Invoke-Ddl -Query @'
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
        int 'ID' -NotNull
    }

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

function Pop-Migration
{
    Remove-Table 'AddColumnNoDefaultsAllNull'
    Invoke-Ddl 'drop xml schema collection EmptyXsd'
}
"@ | New-TestMigration -Name 'AddColumnNoDefaultsAllNull'

        Invoke-RTRivet -Push 'AddColumnNoDefaultsAllNull'

        (Test-Table -Name 'AddColumnNoDefaultsAllNull') | Should Be $true

        $commonArgs = @{ TableName = 'AddColumnNoDefaultsAllNull' }
        Assert-Column -Name 'varchar' 'varchar' -Size 20 -Description 'varchar(20) null' @commonArgs
        Assert-Column -Name 'varcharmax' 'varchar' -Max -Description 'varchar(max) null' @commonArgs
        Assert-Column -Name 'char' 'char' -Size 10 -Description 'char(10) null' @commonArgs
        Assert-Column -Name 'nvarchar' 'nvarchar' -Size 30 -Description 'nvarchar(30) null' @commonArgs
        Assert-Column -Name 'nvarcharmax' 'nvarchar' -Max -Description 'nvarchar(max) null' @commonArgs
        Assert-Column -Name 'nchar' 'nchar' -Size 35 -Description 'nchar(35) null' @commonArgs
        Assert-Column -Name 'binary' 'binary' -Size 40 -Description 'binary(40) null' @commonArgs
        Assert-Column -Name 'varbinary' 'varbinary' -Size 45 -Description 'varbinary(45) null' @commonArgs
        Assert-Column -Name 'varbinarymax' 'varbinary' -Max -Description 'varbinary(max) null' @commonArgs
        Assert-Column -Name 'bigint' 'bigint' -Description 'bigint null' @commonArgs
        Assert-Column -Name 'int' 'int' -Description 'int null' @commonArgs
        Assert-Column -Name 'smallint' 'smallint' -Description 'smallint null' @commonArgs
        Assert-Column -Name 'tinyint' 'tinyint' -Description 'tinyint null' @commonArgs
        Assert-Column -Name 'decimal' 'decimal' -Precision 4 -Description 'decimal(4) null' @commonArgs
        Assert-Column -Name 'decimalwithscale' 'decimal' -Precision 5 -Scale 5 -Description 'decimal(5,5) null' @commonArgs
        Assert-Column -Name 'bit' 'bit' -Description 'bit null' @commonArgs
        Assert-Column -Name 'money' 'money' -Description 'money null' @commonArgs
        Assert-Column -Name 'smallmoney' 'smallmoney' -Description 'smallmoney null' @commonArgs
        Assert-Column -Name 'float' 'float' -Description 'float null' @commonArgs
        Assert-Column -Name 'floatwithprecision' 'float' -Precision 53 -Description 'float(53) null' @commonArgs
        Assert-Column -Name 'real' 'real' -Description 'real null' @commonArgs
        Assert-Column -Name 'date' 'date' -Description 'date null' @commonArgs
        Assert-Column -Name 'datetime2' 'datetime2' -Description 'datetime2 null' @commonArgs
        Assert-Column -Name 'datetimeoffset' 'datetimeoffset' -Description 'datetimeoffset null' @commonArgs
        Assert-Column -Name 'smalldatetime' 'smalldatetime' -Description 'smalldatetime null' @commonArgs
        Assert-Column -Name 'time' 'time' -Description 'time null' @commonArgs
        Assert-Column -Name 'xml' 'xml' -Description 'xml null' @commonArgs
        Assert-Column -Name 'sql_variant' 'sql_variant' -Description 'sql_variant null' @commonArgs
        Assert-Column -Name 'uniqueidentifier' 'uniqueidentifier' -Description 'uniqueidentifier null' @commonArgs
        Assert-Column -Name 'hierarchyid' 'hierarchyid' -Description 'hierarchyid null' @commonArgs

        Assert-Column -Name 'timestamp' 'timestamp' -NotNull -Description 'timestamp' @commonArgs
    }

    It 'should add not nullable columns with defaults' {
    @"
function Push-Migration()
{
    Invoke-Ddl -Query @'
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

    Add-Table 'AddColumnDefaultsNotNull' {
        int 'id' -NotNull
    }

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
    Remove-Table 'AddColumnDefaultsNotNull'
    Invoke-Ddl 'drop xml schema collection EmptyXsd'
}
"@ | New-TestMigration -Name 'AddColumnDefaultsNotNull'

        Invoke-RTRivet -Push 'AddColumnDefaultsNotNull'

        (Test-Table -Name 'AddColumnDefaultsNotNull') | Should Be $true

        $commonArgs = @{ TableName = 'AddColumnDefaultsNotNull'; NotNull = $true; }
        Assert-Column -Name 'varchar' 'varchar' -Size 20 -Default "'varchar'" -Description 'varchar(20) not null' @commonArgs
        Assert-Column -Name 'varcharmax' 'varchar' -Max -Default "'varcharmax'" -Description 'varchar(max) not null' @commonArgs
        Assert-Column -Name 'char' 'char' -Size 10 -Default "'char'" -Description 'char(10) not null' @commonArgs
        Assert-Column -Name 'nvarchar' 'nvarchar' -Size 30 -Default "'nvarchar'" -Description 'nvarchar(30) not null' @commonArgs
        Assert-Column -Name 'nvarcharmax' 'nvarchar' -Max -Default "'nvarcharmax'" -Description 'nvarchar(max) not null' @commonArgs
        Assert-Column -Name 'nchar' 'nchar' -Size 35 -Default "'nchar'" -Description 'nchar(35) not null' @commonArgs
        Assert-Column -Name 'binary' 'binary' -Size 40 -Default 1 -Description 'binary(40) not null' @commonArgs
        Assert-Column -Name 'varbinary' 'varbinary' -Size 45 -Default 2 -Description 'varbinary(45) not null' @commonArgs
        Assert-Column -Name 'varbinarymax' 'varbinary' -Max -Default 3 -Description 'varbinary(max) not null' @commonArgs
        Assert-Column -Name 'bigint' 'bigint' -Default ([int64]::MaxValue) -Description 'bigint not null' @commonArgs
        Assert-Column -Name 'int' 'int' -Default ([int]::MaxValue) -Description 'int not null' @commonArgs
        Assert-Column -Name 'smallint' 'smallint' -Default ([int16]::MaxValue) -Description 'smallint not null' @commonArgs
        Assert-Column -Name 'tinyint' 'tinyint' -Default ([byte]::MaxValue) -Description 'tinyint not null' @commonArgs
        Assert-Column -Name 'decimal' 'decimal' -Precision 4 -Default '3.33' -Description 'decimal(4) not null' @commonArgs
        Assert-Column -Name 'decimalwithscale' 'decimal' -Precision 5 -Scale 5 -Default '4.44' -Description 'decimal(5,5) not null' @commonArgs
        Assert-Column -Name 'bit' 'bit' -Default '1' -Description 'bit not null' @commonArgs
        Assert-Column -Name 'money' 'money' -Default '6.66' -Description 'money not null' @commonArgs
        Assert-Column -Name 'smallmoney' 'smallmoney' -Default '7.77' -Description 'smallmoney not null' @commonArgs
        Assert-Column -Name 'float' 'float' -Default '8.88' -Description 'float not null' @commonArgs
        Assert-Column -Name 'floatwithprecision' 'float' -Precision 53 -Default '9.99' -Description 'float(53) not null' @commonArgs
        Assert-Column -Name 'real' 'real' -Default '10.10' -Description 'real not null' @commonArgs
        Assert-Column -Name 'date' 'date' -Default 'getdate()' -Description 'date not null' @commonArgs
        Assert-Column -Name 'datetime2' 'datetime2' -Default 'getdate()' -Description 'datetime2 not null' @commonArgs
        Assert-Column -Name 'datetimeoffset' 'datetimeoffset' -Default 'getdate()' -Description 'datetimeoffset not null' @commonArgs
        Assert-Column -Name 'smalldatetime' 'smalldatetime' -Default 'getdate()' -Description 'smalldatetime not null' @commonArgs
        Assert-Column -Name 'time' 'time' -Default 'getdate()' -Description 'time not null' @commonArgs
        Assert-Column -Name 'xml' 'xml' -Default "'<empty />'" -Description 'xml not null' @commonArgs
        Assert-Column -Name 'sql_variant' 'sql_variant' -Default "'sql_variant'" -Description 'sql_variant not null' @commonArgs
        Assert-Column -Name 'uniqueidentifier' 'uniqueidentifier' -Default 'newid()' -Description 'uniqueidentifier not null' @commonArgs
        Assert-Column -Name 'hierarchyid' 'hierarchyid' -Default '0x11' -Description 'hierarchyid not null' @commonArgs
    }

    It 'should create identities' {
        @'

function Push-Migration()
{
    Add-Table BigIntIdentity {
        varchar 'name' -Max -NotNull
    }

    Add-Table IntIdentity {
        varchar 'name' -notNull -Max
    }

    Add-Table SmallIntIdentity {
        varchar 'name' -Max -NotNull
    }

    Add-Table TinyIntIdentity {
        varchar 'name' -Max -NotNull
    }

    Add-Table DecimalIdentity {
        varchar 'name' -Max -NotNull
    }

    Update-Table -Name 'BigIntIdentity' -AddColumn {  BigInt 'bigintidentity' -Identity 1 2  }
    Update-Table -Name 'IntIdentity' -AddColumn {  Int 'intidentity' -Identity 3 5  }
    Update-Table -Name 'SmallIntIdentity' -AddColumn {  SmallInt 'smallintidentity' -Identity 7 11  }
    Update-Table -Name 'TinyIntIdentity' -AddColumn {  TinyInt 'tinyintidentity' -Identity 13 17  }
    Update-Table -Name 'DecimalIdentity' -AddColumn {  Decimal 'decimalidentity' -Precision 5 -Identity -Seed 37 -Increment 41  }
}

function Pop-Migration()
{
    Remove-Table 'BigIntIdentity'
    Remove-Table 'IntIdentity'
    Remove-Table 'SmallIntIdentity'
    Remove-Table 'TinyIntIdentity'
    Remove-Table 'DecimalIdentity'
}
'@ | New-TestMigration -Name 'AddColumnIdentityTables'

        Invoke-RTRivet -Push 'AddColumnIdentityTables'

        Assert-Table 'BigIntIdentity'
        Assert-Column -Name 'bigintidentity' 'bigint' -Seed 1 -Increment 2 -NotNull -TableName 'BigIntIdentity'

        Assert-Table 'IntIdentity'
        Assert-Column -Name 'intidentity' 'int' -Seed 3 -Increment 5 -NotNull -TableName 'IntIdentity'

        Assert-Table 'SmallIntIdentity'
        Assert-Column -Name 'smallintidentity' 'smallint' -Seed 7 -Increment 11 -NotNull -TableName 'SmallIntIdentity'

        Assert-Table 'TinyIntIdentity'
        Assert-Column -Name 'tinyintidentity' 'tinyint' -Seed 13 -Increment 17 -NotNull -TableName 'TinyIntIdentity'

        Assert-Table 'DecimalIdentity'
        Assert-Column -Name 'decimalidentity' 'decimal' -Size 5 -Seed 37 -Increment 41 -NotNull -TableName 'DecimalIdentity'
    }

    It 'should create row guid col' {
        @'
function Push-Migration()
{
    Add-Table 'WithRowGuidCol' {
        varchar 'name' -Max -NotNull
    }
    
    Update-Table -Name 'WithRowGuidCol' -AddColumn {  UniqueIdentifier 'uniqueidentiferasrowguidcol' -RowGuidCol  }
}

function Pop-Migration()
{
    Remove-Table 'WithRowGuidCol'
}
'@ | New-TestMigration -Name 'AddColumnRowGuidCol'

        Invoke-RTRivet -Push 'AddColumnRowGuidCol'

        Assert-Table 'WithRowGuidCol'

        Assert-Column -Name 'uniqueidentiferasrowguidcol' 'uniqueidentifier' -RowGuidCol -TableName 'WithRowGuidCol'
    }

        It 'should support xml document' {
        @"
function Push-Migration()
{
    Invoke-Ddl -Query @'
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
    Add-Table 'WithXmlDocument' {
        varchar 'name' -max -notnull
    }
    
    Update-Table -Name 'WithXmlDocument' -AddColumn {  Xml 'xmlasdocument' -Document -XmlSchemaCollection 'EmptyXsd'  }
}

function Pop-Migration()
{
    Remove-Table 'WithXmlDocument'
    Invoke-Ddl 'drop xml schema collection EmptyXsd'
}
"@ | New-TestMigration -Name 'AddColumnXmlDocument'

        Invoke-RTRivet -Push 'AddColumnXmlDocument'

        Assert-Table 'WithXmlDocument'

        Assert-Column -Name 'xmlasdocument' 'xml' -Document -TableName 'WithXmlDocument'
    }

# This test won't work unless file streams are setup.  Don't know how to do that so ignoring this test for now.
    It -Skip 'should support file stream' {
        @"
function Push-Migration()
{
    Add-Table 'WithVarBinaryFileStream' {
        varchar 'name' -Max -NotNull
        varbinary 'firstvarbinary' -Max -Filestream
        uniqueidentifier 'rowguidcol' -NotNull -RowGuidCol
    } -FileStream "default"
    Add-PrimaryKey 'WithVarBinaryFileStream' 'rowguidcol'
    Update-Table -Name 'WithVarBinaryFileStream' {  VarBinary 'filestreamvarbinary' -FileStream }
}

function Pop-Migration()
{
    Remove-Table 'WithVarBinaryFileStream'
}
"@ | New-TestMigration -Name 'AddColumnVarBinaryFileStream'
        Invoke-RTRivet -Push 'AddColumnVarBinaryFileStream'

        Assert-Table 'WithVarBinaryFileStream'

        Assert-Column -Name 'filestreamvarbinary' 'varbinary' -Max -FileStream -TableName 'WithVarBinaryFileStream'
    }

    It 'should support collation' {
        @"

function Push-Migration()
{
    Add-Table 'WithCustomCollation' {
        varchar 'name' -NotNull -Max
    }

    Update-Table -Name 'WithCustomCollation' -AddColumn {
        Char 'char' 15 -Collation 'Japanese_BIN'
        NChar 'nchar' 15 -Collation 'Korean_Wansung_BIN'
        VarChar 'varchar' -Max -Collation 'Chinese_Taiwan_Stroke_BIN'
        NVarChar 'nvarchar' -Max -Collation 'Thai_BIN'
    }
}

function Pop-Migration()
{
    Remove-Table 'WithCustomCollation'
}
"@ | New-TestMigration -Name 'AddColumnCollation'

        Invoke-RTRivet -Push 'AddColumnCollation'

        Assert-Table 'WithCustomCollation'

        Assert-Column -Name 'char' 'char' -Collation 'Japanese_BIN' -TableName 'WithCustomCollation'    
        Assert-Column -Name 'nchar' 'nchar' -Collation 'Korean_Wansung_BIN' -TableName 'WithCustomCollation'    
        Assert-Column -Name 'varchar' 'varchar' -Collation 'Chinese_Taiwan_Stroke_BIN' -TableName 'WithCustomCollation'    
        Assert-Column -Name 'nvarchar' 'nvarchar' -Collation 'Thai_BIN' -TableName 'WithCustomCollation'    
    }


    It 'should add sparse columns' {
    @"
function Push-Migration()
{
    Invoke-Ddl -Query @'
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

    Add-Table 'WithSparseColumns' {
        varchar 'name' -Max -NotNull
    }

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
    Remove-Table 'WithSparseColumns'
    Invoke-Ddl 'drop xml schema collection EmptyXsd'
}

"@ | New-TestMigration -Name 'AddColumnSparse'

        Invoke-RTRivet -Push 'AddColumnSparse'

        Assert-Table -Name 'WithSparseColumns'

        $commonArgs = @{ TableName = 'WithSparseColumns' }
        Assert-Column -Name 'varchar' 'varchar' -Size 20 -Sparse -Description 'varchar(20) sparse' @commonArgs
        Assert-Column -Name 'varcharmax' 'varchar' -Max -Sparse -Description 'varchar(max) sparse' @commonArgs
        Assert-Column -Name 'char' 'char' -Size 10 -Sparse -Description 'char(10) sparse' @commonArgs
        Assert-Column -Name 'nvarchar' 'nvarchar' -Size 30 -Sparse -Description 'nvarchar(30) sparse' @commonArgs
        Assert-Column -Name 'nvarcharmax' 'nvarchar' -Max -Sparse -Description 'nvarchar(max) sparse' @commonArgs
        Assert-Column -Name 'nchar' 'nchar' -Size 35 -Sparse -Description 'nchar(35) sparse' @commonArgs
        Assert-Column -Name 'binary' 'binary' -Size 40 -Sparse -Description 'binary(40) sparse' @commonArgs
        Assert-Column -Name 'varbinary' 'varbinary' -Size 45 -Sparse -Description 'varbinary(45) sparse' @commonArgs
        Assert-Column -Name 'varbinarymax' 'varbinary' -Max -Sparse -Description 'varbinary(max) sparse' @commonArgs
        Assert-Column -Name 'bigint' 'bigint' -Sparse -Description 'bigint sparse' @commonArgs
        Assert-Column -Name 'int' 'int' -Sparse -Description 'int sparse' @commonArgs
        Assert-Column -Name 'smallint' 'smallint' -Sparse -Description 'smallint sparse' @commonArgs
        Assert-Column -Name 'tinyint' 'tinyint' -Sparse -Description 'tinyint sparse' @commonArgs
        Assert-Column -Name 'decimal' 'decimal' -Precision 4 -Sparse -Description 'decimal(4) sparse' @commonArgs
        Assert-Column -Name 'decimalwithscale' 'decimal' -Precision 5 -Scale 5 -Sparse -Description 'decimal(5,5) sparse' @commonArgs
        Assert-Column -Name 'bit' 'bit' -Sparse -Description 'bit sparse' @commonArgs
        Assert-Column -Name 'money' 'money' -Sparse -Description 'money sparse' @commonArgs
        Assert-Column -Name 'smallmoney' 'smallmoney' -Sparse -Description 'smallmoney sparse' @commonArgs
        Assert-Column -Name 'float' 'float' -Sparse -Description 'float sparse' @commonArgs
        Assert-Column -Name 'floatwithprecision' 'float' -Precision 53 -Sparse -Description 'float(53) sparse' @commonArgs
        Assert-Column -Name 'real' 'real' -Sparse -Description 'real sparse' @commonArgs
        Assert-Column -Name 'date' 'date' -Sparse -Description 'date sparse' @commonArgs
        Assert-Column -Name 'datetime2' 'datetime2' -Sparse -Description 'datetime2 sparse' @commonArgs
        Assert-Column -Name 'datetimeoffset' 'datetimeoffset' -Sparse -Description 'datetimeoffset sparse' @commonArgs
        Assert-Column -Name 'smalldatetime' 'smalldatetime' -Sparse -Description 'smalldatetime sparse' @commonArgs
        Assert-Column -Name 'time' 'time' -Sparse -Description 'time sparse' @commonArgs
        Assert-Column -Name 'xml' 'xml' -Sparse -Description 'xml sparse' @commonArgs
        Assert-Column -Name 'sql_variant' 'sql_variant' -Sparse -Description 'sql_variant sparse' @commonArgs
        Assert-Column -Name 'uniqueidentifier' 'uniqueidentifier' -Sparse -Description 'uniqueidentifier sparse' @commonArgs
        Assert-Column -Name 'hierarchyid' 'hierarchyid' -Sparse -Description 'hierarchyid sparse' @commonArgs
    }


    It 'should create identities not for replication' {
    @"
function Push-Migration()
{
    Add-Table BigIntIdentity {
        varchar 'name' -Max -NotNull
    }

    Add-Table IntIdentity {
        varchar 'name' -notNull -Max
    }

    Add-Table SmallIntIdentity {
        varchar 'name' -Max -NotNull
    }

    Add-Table TinyIntIdentity {
        varchar 'name' -Max -NotNull
    }

    Add-Table DecimalIdentity {
        varchar 'name' -Max -NotNull
    }
    
    Update-Table -Name 'BigIntIdentity' -AddColumn {  BigInt 'bigintidentity' -Identity 1 2 -NotForReplication  }
    Update-Table -Name 'IntIdentity' -AddColumn {  Int 'intidentity' -Identity 3 5 -NotForReplication  }
    Update-Table -Name 'SmallIntIdentity' -AddColumn {  SmallInt 'smallintidentity' -Identity 7 11 -NotForReplication  }
    Update-Table -Name 'TinyIntIdentity' -AddColumn {  TinyInt 'tinyintidentity' -Identity 13 17 -NotForReplication  }
    Update-Table -Name 'DecimalIdentity' -AddColumn {  Decimal 'decimalidentity' -Precision 5 -Identity -Seed 37 -Increment 41 -NotForReplication  }
}

function Pop-Migration()
{
    Remove-Table 'BigIntIdentity'
    Remove-Table 'IntIdentity'
    Remove-Table 'SmallIntIdentity'
    Remove-Table 'TinyIntIdentity'
    Remove-Table 'DecimalIdentity'
}
"@ | New-TestMigration -Name 'AddColumnNotForReplication'

        Invoke-RTRivet -Push 'AddColumnNotForReplication'

        Assert-Table 'BigIntIdentity'
        Assert-Column -Name 'bigintidentity' 'bigint' -Seed 1 -Increment 2 -NotNull -NotForReplication  -TableName 'BigIntIdentity'

        Assert-Table 'IntIdentity'
        Assert-Column -Name 'intidentity' 'int' -Seed 3 -Increment 5 -NotNull -NotForReplication  -TableName 'IntIdentity'

        Assert-Table 'SmallIntIdentity'
        Assert-Column -Name 'smallintidentity' 'smallint' -Seed 7 -Increment 11 -NotNull -NotForReplication  -TableName 'SmallIntIdentity'

        Assert-Table 'TinyIntIdentity'
        Assert-Column -Name 'tinyintidentity' 'tinyint' -Seed 13 -Increment 17 -NotNull -NotForReplication  -TableName 'TinyIntIdentity'

        Assert-Table 'DecimalIdentity'
        Assert-Column -Name 'decimalidentity' 'decimal' -Size 5 -Seed 37 -Increment 41 -NotNull -NotForReplication  -TableName 'DecimalIdentity'
    }
}

function GivenMigration
{
    param(
        [Parameter(Mandatory)]
        [string]
        $Content
    )

    $Content | New-TestMigration -Name 'Columns'
}

function Init
{
    Stop-RivetTest
    Start-RivetTest
}

function WhenPushing
{
    Invoke-RTRivet -Push
}

Describe 'Columns.when adding generic columns' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Table 'CustomColumns' {
        New-Column 'ID' 'int' -Identity -Seed 101 -Increment 11 -NotForReplication
        New-Column 'one' 'varchar' -Collation 'Korean_100_CS_AS_KS_WS_SC' -Default '''fubar''' -Description 'snafu'
        New-Column 'two' 'varchar' -Size 50 -NotNull
        New-Column 'three' 'varchar' -Size 51 -Sparse
        New-Column 'four' 'decimal' -Precision 4 -Scale 2 -NotNull
        New-Column 'five' 'decimal' -Precision 3 -Scale 1 -Sparse
        New-Column 'six' 'time' -Scale 4 -NotNull
        New-Column 'seven' 'time' -Scale 3 -Sparse
        New-Column 'eight' 'int' -NotNull
        New-Column 'nine' 'money' -Sparse
        New-Column 'ten' 'uniqueidentifier' -RowGuidCol
        New-Column 'eleven' 'decimal(5,2)'
        New-Column 'twelve' 'varchar' -Max -NotNull
    }
}
function Pop-Migration
{
    Remove-Table 'CustomColumns'
}
'@
    WhenPushing
    try
    {
        It 'should create table with correct columns' {
            Assert-Table 'CustomColumns'
            Assert-Column -TableName 'CustomColumns' -Name 'ID' -DataType 'int' -NotNull -Seed 101 -Increment 11 -NotForReplication
            Assert-Column -TableName 'CustomColumns' -Name 'one' -DataType 'varchar' -Size 1 -Collation 'Korean_100_CS_AS_KS_WS_SC' -Default 'fubar' -Description 'snafu'
            Assert-Column -TableName 'CustomColumns' -Name 'two' -DataType 'varchar' -Size 50 -NotNull
            Assert-Column -TableName 'CustomColumns' -Name 'three' -DataType 'varchar' -Size 51 -Sparse
            Assert-Column -TableName 'CustomColumns' -Name 'four' -DataType 'decimal' -Precision 4 -Scale 2 -NotNull
            Assert-Column -TableName 'CustomColumns' -Name 'five' -DataType 'decimal' -Precision 3 -Scale 1 -Sparse
            Assert-Column -TableName 'CustomColumns' -Name 'six' -DataType 'time' -Scale 4 -NotNull
            Assert-Column -TableName 'CustomColumns' -Name 'seven' -DataType 'time' -Scale 3 -Sparse
            Assert-Column -TableName 'CustomColumns' -Name 'eight' -DataType 'int' -NotNull
            Assert-Column -TableName 'CustomColumns' -Name 'nine' -DataType 'money' -Sparse
            Assert-Column -TableName 'CustomColumns' -Name 'ten' -DataType 'uniqueidentifier' -RowGuidCol
            Assert-Column -TableName 'CustomColumns' -Name 'eleven' -DataType 'decimal' -Precision 5 -Scale 2
            Assert-Column -TableName 'CustomColumns' -Name 'twelve' -DataType 'varchar' -Max -NotNull
        }
    }
    finally
    {
        Invoke-RTRivet -Pop
        Stop-RivetTest
    }
}
