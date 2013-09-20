function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'UpdateColumn' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldUpdateColumnFromInttoBigInt
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Int 'id'
    } -Option 'data_compression = none'

    Update-Column -TableName 'Foobar' -Name 'id' -BigInt
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateDateColumn'

    Invoke-Rivet -Push 'UpdateDateColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'BigInt' -TableName 'Foobar'
}

function Test-ShouldUpdateColumnFromBinarytoVarBinary
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Binary 'id' -NotNull -Size 50 
    }

    Update-Column -TableName 'Foobar' -Name 'id' -VarBinary -Size 40 -Sparse
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ShouldUpdateColumnFromBinarytoVarBinary'

    Invoke-Rivet -Push 'ShouldUpdateColumnFromBinarytoVarBinary'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarBinary' -TableName 'Foobar' -Sparse -Size 40 
}

function Test-ShouldUpdateColumnFromNChartoNVarChar
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        NChar 'id' 
    }

    Update-Column -TableName 'Foobar' -Name 'id' -NVarChar -Collation "Chinese_Taiwan_Stroke_CI_AS" -NotNull
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ShouldUpdateColumnFromNChartoNVarChar'

    Invoke-Rivet -Push 'ShouldUpdateColumnFromNChartoNVarChar'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -NotNull -Max -Collation "Chinese_Taiwan_Stroke_CI_AS"
}

function Test-ShouldUpdateColumnFromNVarChartoXml
{

@"
function Push-Migration
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

    Add-Table -Name 'WithXmlContent' -Column {
        VarChar 'One' -NotNull
        Xml 'Two' -XmlSchemaCollection 'EmptyXsd'
    }

    Update-Column -TableName 'WithXmlContent' -Name 'Two' -Xml -XmlSchemaCollection 'EmptyXsd'
}

function Pop-Migration
{
    
}
"@ | New-Migration -Name 'ShouldUpdateColumnFromNVarChartoXml'

    Invoke-Rivet -Push 'ShouldUpdateColumnFromNVarChartoXml'
    
    Assert-Table 'WithXmlContent'
    Assert-Column -Name 'Two' -DataType 'Xml' -TableName 'WithXmlContent'
}