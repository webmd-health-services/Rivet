
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Add-PrimaryKey' {
    BeforeEach { Start-RivetTest }
    AfterEach { Stop-RivetTest }

    It 'should add primary key' {
        # Yes.  Spaces in the name so we check the name gets quoted.
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Primary Key' {
            Int 'PK ID' -NotNull
        }

        Add-PrimaryKey 'Primary Key' 'PK ID'
    }

    function Pop-Migration()
    {
        Remove-PrimaryKey -TableName 'Primary Key' -Name '$(New-RTConstraintName -PrimaryKey -TableName 'Primary Key')'
        Remove-Table -Name 'Primary Key'
    }

"@ | New-TestMigration -Name 'AddTableWithPrimaryKey'
        Invoke-RTRivet -Push 'AddTableWithPrimaryKey'
        (Test-Table 'Primary Key') | Should -BeTrue
        Assert-PrimaryKey -TableName 'Primary Key' -ColumnName 'PK ID'
    }

    It 'should add primary key with multiple columns' {
        @'
    function Push-Migration()
    {

        Add-Table -Name 'PrimaryKey' {
            Int 'id' -NotNull
            UniqueIdentifier 'uuid' -NotNull
            DateTimeOffset 'date' -NotNull
        }

        Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id','uuid','date'

    }

    function Pop-Migration()
    {
        Remove-Table 'PrimaryKey'
    }
'@ | New-TestMigration -Name 'AddTableWithPrimaryKeyWithMultipleColumns'
        Invoke-RTRivet -Push 'AddTableWithPrimaryKeyWithMultipleColumns'
        (Test-Table 'PrimaryKey') | Should -BeTrue
        Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id','uuid','date'
    }

    It 'should add non clustered primary key' {
        @'
    function Push-Migration()
    {

        Add-Table -Name 'PrimaryKey' {
            Int 'id' -NotNull
        }

        Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -NonClustered

    }

    function Pop-Migration()
    {
        Remove-Table 'PrimaryKey'
    }
'@ | New-TestMigration -Name 'AddNonClusteredPrimaryKey'
        Invoke-RTRivet -Push 'AddNonClusteredPrimaryKey'
        (Test-Table 'PrimaryKey') | Should -BeTrue
        Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -NonClustered
    }

    It 'should set index options' {
        @'
    function Push-Migration()
    {

        Add-Table -Name 'PrimaryKey' {
            Int 'id' -NotNull
        }

        Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -Option 'IGNORE_DUP_KEY = ON','FILLFACTOR = 75'

    }

    function Pop-Migration()
    {
        Remove-Table 'PrimaryKey'
    }
'@ | New-TestMigration -Name 'SetIndexOptions'
        Invoke-RTRivet -Push 'SetIndexOptions'
        (Test-Table 'PrimaryKey') | Should -BeTrue
        Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -IgnoreDupKey -FillFActor 75
    }

    It 'should add primary key to table in custom schema' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'PrimaryKey' -SchemaName 'rivet' {
            Int 'id' -NotNull
        }

        Add-PrimaryKey -TableName 'PrimaryKey' -SchemaName 'rivet' -ColumnName 'id'

    }

    function Pop-Migration()
    {
        Remove-Table 'PrimaryKey' -SchemaName 'rivet'
    }
'@ | New-TestMigration -Name 'AddPrimaryKeyToTableInCustomSchema'
        Invoke-RTRivet -Push 'AddPrimaryKeyToTableInCustomSchema'
        (Test-Table 'PrimaryKey' -SchemaName 'rivet') | Should -BeTrue
        Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -SchemaName 'rivet'
    }

    It 'should quote primary key name' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'Add-PrimaryKey' {
            Int 'id' -NotNull
        }

        Add-PrimaryKey -TableName 'Add-PrimaryKey' -ColumnName 'id'
    }

    function Pop-Migration()
    {
        Remove-Table 'Add-PrimaryKey'
    }

'@ | New-TestMigration -Name 'AddTableWithPrimaryKey'
        Invoke-RTRivet -Push 'AddTableWithPrimaryKey'
        Assert-PrimaryKey -TableName 'Add-PrimaryKey' -ColumnName 'id'
    }

    It 'should add primary key with custom name' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'Add-PrimaryKey' {
            Int 'id' -NotNull
        }

        Add-PrimaryKey -TableName 'Add-PrimaryKey' -ColumnName 'id' -Name 'Custom'
    }

    function Pop-Migration()
    {
        Remove-Table 'Add-PrimaryKey'
    }

'@ | New-TestMigration -Name 'AddPrimaryKeyWithCustomName'
        Invoke-RTRivet -Push 'AddPrimaryKeyWithCustomName'

        Assert-PrimaryKey -Name 'Custom' -ColumnName 'id'
    }
}
