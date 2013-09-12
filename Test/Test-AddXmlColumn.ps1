function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddXmlColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateXmlColumnWithContent
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
}

function Pop-Migration
{
    
}
"@ | New-Migration -Name 'CreateXmlColumn'

    Invoke-Rivet -Push 'CreateXmlColumn'
    
    Assert-Table 'WithXmlContent'
    Assert-Column -Name 'Two' -DataType 'Xml' -TableName 'WithXmlContent'
}


function Test-ShouldCreateXmlColumnWithDocument
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

    Add-Table -Name 'WithXmlDocument' -Column {
        VarChar 'One' -NotNull
        Xml 'Two' -Document -XmlSchemaCollection 'EmptyXsd'
    }
}

function Pop-Migration
{
    
}
"@ | New-Migration -Name 'CreateXmlColumn'

    Invoke-Rivet -Push 'CreateXmlColumn'
    
    Assert-Table 'WithXmlDocument'
    Assert-Column -Name 'Two' -DataType 'Xml' -TableName 'WithXmlDocument'
}