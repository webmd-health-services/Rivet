
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Setup
{
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldUpdateColumnFromInttoBigIntWithDescription
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Int 'id' -Description 'Foo'
    } -Option 'data_compression = none'

    Update-Table -Name 'Foobar' -UpdateColumn {
        BigInt 'id' -Description 'Bar'
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'UpdateDateColumnWithDescription'

    Invoke-RTRivet -Push 'UpdateDateColumnWithDescription'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'BigInt' -TableName 'Foobar' -Description 'Bar'
}

function Test-ShouldUpdateColumnFromBinarytoVarBinary
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Binary 'id' -NotNull -Size 50 
    }

    Update-Table -Name 'Foobar' -UpdateColumn {
        VarBinary 'id' -Size 40 -Sparse
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'ShouldUpdateColumnFromBinarytoVarBinary'

    Invoke-RTRivet -Push 'ShouldUpdateColumnFromBinarytoVarBinary'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarBinary' -TableName 'Foobar' -Sparse -Size 40 
}

function Test-ShouldUpdateColumnFromNChartoNVarChar
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        NChar 'id' 30
    }

    Update-Table -Name 'Foobar' -UpdateColumn {
        NVarChar 'id' -Max -Collation "Chinese_Taiwan_Stroke_CI_AS" -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'ShouldUpdateColumnFromNChartoNVarChar'

    Invoke-RTRivet -Push 'ShouldUpdateColumnFromNChartoNVarChar'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -NotNull -Max -Collation "Chinese_Taiwan_Stroke_CI_AS"
}

function Test-ShouldUpdateColumnFromNVarChartoXml
{

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

    Add-Table -Name 'WithXmlContent' -Column {
        VarChar 'One' -Max -NotNull
        Xml 'Two' -XmlSchemaCollection 'EmptyXsd'
    }

    Update-Table -Name 'WithXmlContent' -UpdateColumn{
        Xml 'Two' -XmlSchemaCollection 'EmptyXsd'
    }
}

function Pop-Migration
{
    Remove-Table 'WithXmlContent'
    Invoke-Ddl 'drop xml schema collection EmptyXsd'
}
"@ | New-TestMigration -Name 'ShouldUpdateColumnFromNVarChartoXml'

    Invoke-RTRivet -Push 'ShouldUpdateColumnFromNVarChartoXml'
    
    Assert-Table 'WithXmlContent'
    Assert-Column -Name 'Two' -DataType 'Xml' -TableName 'WithXmlContent'
}

function Test-ShouldUpdateColumnAfterAddColumnInUpdateTable
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Int 'id' -Description 'Foo'
    }

    Update-Table -Name 'Foobar' -AddColumn {
        VarChar 'id2' -Max -Description 'Foo2'
    }
    
    Update-Table -Name 'FooBar' -UpdateColumn {
        BigInt 'id2' -Description 'Bar'
    } 

    Update-Table -Name 'Foobar' -UpdateColumn {
        VarChar 'id' -Max -Description 'Bar2'
    } -AddColumn {
        BigInt 'id3' -Description 'Foo'
    } 
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'UpdateDateColumnWithDescription'

    Invoke-RTRivet -Push 'UpdateDateColumnWithDescription'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -Max -Description 'Bar2'
    Assert-Column -Name 'id2' -DataType 'BigInt' -TableName 'Foobar' -Description 'Bar'
    Assert-Column -Name 'id3' -DataType 'BigInt' -TableName 'Foobar' -Description 'Foo'
}
