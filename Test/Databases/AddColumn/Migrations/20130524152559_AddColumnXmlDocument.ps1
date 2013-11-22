
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
    create table WithXmlDocument (
        name varchar(max) not null
    )
'@
    
    Update-Table -Name 'WithXmlDocument' -AddColumn {  Xml 'xmlasdocument' -Document -XmlSchemaCollection 'EmptyXsd'  }
}

function Pop-Migration()
{
    Invoke-Query -Query @'
        drop table WithXmlDocument
'@}
