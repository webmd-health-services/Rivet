
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
    Remove-Item -Path 'alias:GivenMigration'
    Remove-Item -Path 'alias:WhenMigrating'
    Remove-Item -Path 'alias:ThenTable'

    $script:testDirPath = $null
    $script:testNum = 0
    $script:rivetJsonPath = $null
    $script:dbName = 'New-XmlColumn'

    function GivenMigration
    {
        param(
            [Parameter(Mandatory, Position=0)]
            [String] $Named,

            [Parameter(Mandatory, Position=1)]
            [String] $WithContent
        )

        $WithContent |
            New-TestMigration -Named $Named -DatabaseName $script:dbName -ConfigFilePath $script:rivetJsonPath
    }

    function ThenMigrationPoppable
    {
        { Invoke-Rivet -Pop -ConfigFilePath $script:rivetJsonPath } | Should -Not -Throw
    }

    function ThenColumn
    {
        param(
            [String] $Named,

            [String] $OnTable,

            [String] $HasDataType
        )

        Assert-Column -Name $Named -DataType $HasDataType -TableName $OnTable -DatabaseName $script:dbName
    }

    function ThenTable
    {
        [CmdletBinding()]
        param(
            [String] $Named,

            [switch] $Exists
        )

        Assert-Table 'WithXmlContent' -Exists -DatabaseName $script:dbName
    }

    function WhenPushing
    {
        Invoke-Rivet -Push -ConfigFilePath $script:rivetJsonPath
    }
}

Describe 'New-XmlColumn' {
    BeforeAll {
        Remove-RivetTestDatabase -Name $script:dbName
        Invoke-RivetTestQuery -DatabaseName 'master' -Query "create database [${script:dbName}]"
        Invoke-RivetTestQuery -DatabaseName $script:dbName -Query @'
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
    }

    BeforeEach {
        $script:testDirPath = Join-Path -Path $TestDrive -ChildPath ($script:testNum++)
        New-Item -Path $script:testDirPath -ItemType Directory
        $Global:Error.Clear()
        $script:migrations = @()
        $script:rivetJsonPath = GivenRivetJsonFile -In $script:testDirPath -Database $script:dbName -PassThru
    }

    It 'should create xml column with content' {
        GivenMigration 'CreateXmlColumn' @"
            function Push-Migration
            {
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
"@

        WhenPushing
        ThenTable 'WithXmlContent' -Exists
        ThenColumn 'Two' -OnTable 'WithXmlContent' -HasDataType 'Xml'
    }


    It 'should create xml column with document' {
        GivenMigration 'CreateXmlColumn' @"
            function Push-Migration
            {
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
"@

        WhenPushing
        ThenTable 'WithXmlDocument' -Exists
        ThenColumn 'Two' -OnTable 'WithXmlDocument' -HasDataType 'Xml'
    }

    It 'does not require xml schema' {
        GivenMigration -Named 'Migration' @'
            function Push-Migration
            {
                Add-Table -Name 'WithXmlColumn' -Column {
                    Xml 'Two'
                }
            }
            function Pop-Migration
            {
                Remove-Table 'WithXmlColumn'
            }
'@
        WhenPushing
        ThenTable 'WithXmlColumn' -Exists
        ThenColumn 'Two' -OnTable 'WithXmlColumn' -HasDataType 'Xml'
        ThenMigrationPoppable
    }
}
