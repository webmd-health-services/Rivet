
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'int' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create int with nullable' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateIntWithNullable'

        Invoke-RTRivet -Push 'CreateIntWithNullable'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar'
    }

    It 'should create int with not null' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateIntWithNotNull'

        Invoke-RTRivet -Push 'CreateIntWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -NotNull
    }

    It 'should create int with sparse' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateIntWithSparse'

        Invoke-RTRivet -Push 'CreateIntWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -Sparse
    }

    It 'should create int with identity' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID -Identity
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateIntWithIdentity'

        Invoke-RTRivet -Push 'CreateIntWithIdentity'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1
    }

    It 'should create int with identity not for replication' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID -Identity -NotForReplication
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateIntWithIdentityNotForReplication'

        Invoke-RTRivet -Push 'CreateIntWithIdentityNotForReplication'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -NotForReplication
    }

    It 'should create int with identity custom seed custom increment' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID -Identity -NotForReplication -Seed 4 -Increment 4
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateIntWithIdentityCustomSeedCustomIncrement'

        Invoke-RTRivet -Push 'CreateIntWithIdentityCustomSeedCustomIncrement'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -NotNull -Seed 4 -Increment 4 -NotForReplication
    }

    It 'should create int with custom value custom description' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID  -Default 21 -Description 'Test'
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateIntWithCustomValueCustomDescription'

        Invoke-RTRivet -Push 'CreateIntWithCustomValueCustomDescription'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -Default 21 -Description 'Test'
    }
}
