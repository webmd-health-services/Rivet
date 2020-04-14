
& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'Rename-Object' {
    BeforeEach { 
        Start-RivetTest
    }

    AfterEach { 
        Stop-RivetTest
    }

    It 'should rename table' {
        @'
function Push-Migration
{
    Add-Schema 'do.i.get.escaped'
    Add-Table -SchemaName 'do.i.get.escaped' -Name 'Add.Table' -Description 'Testing Add-Table migration' -Column {
        VarChar 'varchar' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        BigInt 'id' -Identity
    } -Option 'data_compression = none'

    Rename-Object -SchemaName 'do.i.get.escaped' 'Add.Table' 'Rename Table'
}

function Pop-Migration
{
    Remove-Table -SchemaName 'do.i.get.escaped' 'Rename Table'
    Remove-Schema 'do.i.get.escaped'
}

'@ | New-TestMigration -Name 'RenameTable'

        Invoke-RTRivet -Push 'RenameTable'

        Assert-Table -SchemaName 'do.i.get.escaped' 'Rename Table' -Description 'Testing Add-Table migration'
        Assert-Column -Name 'varchar' 'varchar' -NotNull -Description 'varchar(max) constraint DF_AddTable_varchar default default' -TableName 'Rename Table' -SchemaName 'do.i.get.escaped'
        Assert-Column -Name 'id' 'bigint' -NotNull -Seed 1 -Increment 1 -TableName 'Rename Table' -SchemaName 'do.i.get.escaped'
    }

    It 'should rename column' {

        @'
function Push-Migration
{
    Add-Table -Name 'Table.Name' -Column {
        VarChar 'bu.zz' -Max
        BigInt 'id' -Identity
    } -Option 'data_compression = none'

    Rename-Column 'Table.Name' 'bu.zz' 'fizz'
}

function Pop-Migration
{
    Remove-Table 'Table.Name'
}

'@ | New-TestMigration -Name 'RenameColumn'

        Invoke-RTRivet -Push 'RenameColumn'

        Assert-Table 'Table.Name'
        Assert-Column -Name 'fizz' -TableName 'Table.Name' -DataType 'varchar'
        Assert-Column -Name 'id' 'bigint' -NotNull -Seed 1 -Increment 1 -TableName 'Table.Name'
    }

    It 'should rename index' {
        @'
function Push-Migration
{
    Add-Schema 'the.schema'
    Add-Table -SchemaName 'the.schema' -Name 'Add.Index' {
        Int 'Index.Me' -NotNull
    }

    #Add an Index to 'Index.Me'
    Add-Index -SchemaName 'the.schema' -TableName 'Add.Index' -ColumnName 'Index.Me'
    Rename-Index -SchemaName 'the.schema' -TableName 'Add.Index' -Name 'IX_the.schema_Add.Index_Index.Me' -NewName 'IX_AddIndex_Renamed'
}

function Pop-Migration
{
    Remove-Table -SchemaName 'the.schema' 'Add.Index'
    Remove-SChema 'the.schema'
}

'@ | New-TestMigration -Name 'RenameIndex'

        Invoke-RTRivet -Push 'RenameIndex'

        ##Assert Table and Column
        (Test-Table 'Add.Index' -SchemaName 'the.schema') | Should Be $true
        (Test-Column -Name 'Index.Me' -TableName 'Add.Index' -SchemaName 'the.schema') | Should Be $true

        ##Assert Index
        Assert-Index -Name 'IX_AddIndex_Renamed' -ColumnName 'Index.Me'
    }

    It 'should rename constraint' {
        @'
function Push-Migration
{
    Add-Schema 'the.schema'

    Add-Table -SchemaName 'the.schema' -Name 'Source.Table' {
        Int 'source.id' -NotNull
    }

    Add-Table -SchemaName 'the.schema' -Name 'Reference.Table' {
        Int 'reference.id' -NotNull
    }

    Add-PrimaryKey -SchemaName 'the.schema' -TableName 'Reference.Table' -ColumnName 'reference.id'
    Add-ForeignKey -SchemaName 'the.schema' -TableName 'Source.Table' -ColumnName 'source.id' -ReferencesSchema 'the.schema' -References 'Reference.Table' -ReferencedColumn 'reference.id'
    Rename-Object -SchemaName 'the.schema' -Name 'FK_the.schema_Source.Table_the.schema_Reference.Table' -NewName 'FK_Reference.Table_Source.Table'
}

function Pop-Migration
{
    Remove-ForeignKey -SchemaName 'the.schema' 'Source.Table' -Name 'FK_Reference.Table_Source.Table'
    Remove-Table -SchemaName 'the.schema' 'Reference.Table'
    Remove-Table -SchemaName 'the.schema' 'Source.Table'
    Remove-Schema 'the.schema'
}

'@ | New-TestMigration -Name 'RenameConstraint'

        Invoke-RTRivet -Push 'RenameConstraint'

        Assert-ForeignKey -Name 'FK_Reference.Table_Source.Table'
    }
}
