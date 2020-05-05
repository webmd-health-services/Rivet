
& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'tinyint' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should create tiny int with nullable' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            TinyInt ID
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateTinyIntWithNullable'
    
        Invoke-RTRivet -Push 'CreateTinyIntWithNullable'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar'
    }
    
    It 'should create tiny int with not null' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            TinyInt ID -NotNull
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateTinyIntWithNotNull'
    
        Invoke-RTRivet -Push 'CreateTinyIntWithNotNull'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -NotNull
    }
    
    It 'should create tiny int with sparse' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            TinyInt ID -Sparse
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateTinyIntWithSparse'
    
        Invoke-RTRivet -Push 'CreateTinyIntWithSparse'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -Sparse
    }
    
    It 'should create tiny int with identity' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            TinyInt ID -Identity
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateTinyIntWithIdentity'
    
        Invoke-RTRivet -Push 'CreateTinyIntWithIdentity'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1
    }
    
    It 'should create tiny int with identity not for replication' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            TinyInt ID -Identity -NotForReplication
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateTinyIntWithIdentityNotForReplication'
    
        Invoke-RTRivet -Push 'CreateTinyIntWithIdentityNotForReplication'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -NotForReplication
    }
    
    It 'should create tiny int with identity custom seed custom increment' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            TinyInt ID -Identity -NotForReplication -Seed 4 -Increment 4
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateTinyIntWithIdentityCustomSeedCustomIncrement'
    
        Invoke-RTRivet -Push 'CreateTinyIntWithIdentityCustomSeedCustomIncrement'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -NotNull -Seed 4 -Increment 4 -NotForReplication
    }
    
    It 'should create tiny int with custom value custom description' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            TinyInt ID  -Default 21 -Description 'Test'
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateTinyIntWithCustomValueCustomDescription'
    
        Invoke-RTRivet -Push 'CreateTinyIntWithCustomValueCustomDescription'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -Default 21 -Description 'Test'
    }
}
