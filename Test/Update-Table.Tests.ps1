
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Update-Table' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should update column from int to bigint with description' {
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

    It 'should update column from binary to varbinary' {
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

    It 'should update column from nchar to nvarchar' {
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

    It 'should update column from nvarchar to xml' {

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

    It 'should update column after add column in update table' {
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

    It 'should use custom constraint name' {
        GivenMigration -Named 'CustomConstraintNames' @'
function Push-Migration
{
    Add-Table 'CustomConstraintNames' {
        int 'ID'
    }

    Update-Table 'CustomConstraintNames' -AddColumn {
        int 'column2' -NotNull -Default 2 -DefaultConstraintName 'DF_Two'
        int 'column3' -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'CustomConstraintNames'
}
'@
        WhenMigrating 'CustomConstraintNames'
        ThenDefaultConstraint 'DF_Two' -Is 'snafu'
    }

    It 'does not add default constraint to an existing column' {
        GivenMigration -Named 'DefaultConstraintOnExistingColumn' @'
function Push-Migration
{
    Add-Table 'DefaultConstraintOnExistingColumn' {
        int 'column1'
    }

    Update-Table 'DefaultConstraintOnExistingColumn' -UpdateColumn {
        int 'column1' -NotNull -Default 2 -DefaultConstraintName 'DF_Two'
    }
}

function Pop-Migration
{
    Remove-Table 'DefaultConstraintOnExistingColumn'
}
'@
        { WhenMigrating 'DefaultConstraintOnExistingColumn' } | Should -Throw
        ThenWroteError 'Use the Add-DefaultConstraint operation'
        ThenTable 'DefaultConstraintOnExistingColumn' -Not -Exists
    }

    It 'rejects adding an idenity to an existng column' {
        GivenMigration -Named 'IdentityOnExistingColumn' @'
function Push-Migration
{
    Add-Table 'IdentityOnExistingColumn' {
        int 'column1'
    }

    Update-Table 'IdentityOnExistingColumn' -UpdateColumn {
        int 'column1' -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'IdentityOnExistingColumn'
}
'@
        { WhenMigrating 'IdentityOnExistingColumn' } | Should -Throw
        ThenWroteError 'identity'
        ThenTable 'IdentityOnExistingColumn' -Not -Exists
    }
}