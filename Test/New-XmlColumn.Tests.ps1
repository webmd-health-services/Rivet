
& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'New-XmlColumn' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should create xml column with content' {
    
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
    }
    
    function Pop-Migration
    {
        Remove-Table 'WithXmlContent'
        Invoke-Ddl 'drop xml schema collection EmptyXsd'
    }
"@ | New-TestMigration -Name 'CreateXmlColumn'
    
        Invoke-RTRivet -Push 'CreateXmlColumn'
        
        Assert-Table 'WithXmlContent'
        Assert-Column -Name 'Two' -DataType 'Xml' -TableName 'WithXmlContent'
    }
    
    
    It 'should create xml column with document' {
    
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
    
        Add-Table -Name 'WithXmlDocument' -Column {
            VarChar 'One' -Max -NotNull
            Xml 'Two' -Document -XmlSchemaCollection 'EmptyXsd'
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'WithXmlDocument'
        Invoke-Ddl 'drop xml schema collection EmptyXsd'
    }
"@ | New-TestMigration -Name 'CreateXmlColumn'
    
        Invoke-RTRivet -Push 'CreateXmlColumn'
        
        Assert-Table 'WithXmlDocument'
        Assert-Column -Name 'Two' -DataType 'Xml' -TableName 'WithXmlDocument'
    }
}
