
& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'smallint' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should create small int with nullable' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            SmallInt ID
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateSmallIntWithNullable'
    
        Invoke-RTRivet -Push 'CreateSmallIntWithNullable'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'SmallInt' -TableName 'Foobar'
    }
    
    It 'should create small int with not null' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            SmallInt ID -NotNull
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateSmallIntWithNotNull'
    
        Invoke-RTRivet -Push 'CreateSmallIntWithNotNull'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'SmallInt' -TableName 'Foobar' -NotNull
    }
    
    It 'should create small int with sparse' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            SmallInt ID -Sparse
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateSmallIntWithSparse'
    
        Invoke-RTRivet -Push 'CreateSmallIntWithSparse'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'SmallInt' -TableName 'Foobar' -Sparse
    }
    
    It 'should create small int with identity' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            SmallInt ID -Identity
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateSmallIntWithIdentity'
    
        Invoke-RTRivet -Push 'CreateSmallIntWithIdentity'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'SmallInt' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1
    }
    
    It 'should create small int with identity not for replication' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            SmallInt ID -Identity -NotForReplication
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateSmallIntWithIdentityNotForReplication'
    
        Invoke-RTRivet -Push 'CreateSmallIntWithIdentityNotForReplication'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'SmallInt' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -NotForReplication
    }
    
    It 'should create small int with identity custom' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            SmallInt ID -Identity -NotForReplication -Seed 2 -Increment 2
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateSmallIntWithIdentityCustom'
    
        Invoke-RTRivet -Push 'CreateSmallIntWithIdentityCustom'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'SmallInt' -TableName 'Foobar' -NotNull -Seed 2 -Increment 2 -NotForReplication
    }
    
    It 'should create small int with custom value custom description' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            SmallInt ID  -Default 21 -Description 'Test'
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name 'CreateSmallIntWithCustomValueCustomDescription'
    
        Invoke-RTRivet -Push 'CreateSmallIntWithCustomValueCustomDescription'
    
        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'SmallInt' -TableName 'Foobar' -Default 21 -Description 'Test'
    }
}
