
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'bigint' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create big int with nullable' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            BigInt ID
        }
    }

    function Pop-Migration
    {
        Remove-Table Foobar
    }

'@ | New-TestMigration -Name 'CreateBigIntWithNullable'

        Invoke-RTRivet -Push 'CreateBigIntWithNullable'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar'
    }

    It 'should create big int with not null' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            BigInt ID -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table Foobar
    }

'@ | New-TestMigration -Name 'CreateBigIntWithNotNull'

        Invoke-RTRivet -Push 'CreateBigIntWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -NotNull
    }

    It 'should create big int with sparse' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            BigInt ID -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table Foobar
    }

'@ | New-TestMigration -Name 'CreateBigIntWithSparse'

        Invoke-RTRivet -Push 'CreateBigIntWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -Sparse
    }

    It 'should create big int with identity' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            BigInt ID -Identity
        }
    }

    function Pop-Migration
    {
        Remove-Table Foobar
    }

'@ | New-TestMigration -Name 'CreateBigIntWithIdentity'

        Invoke-RTRivet -Push 'CreateBigIntWithIdentity'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1
    }

    It 'should create big int with identity not for replication' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            BigInt ID -Identity -NotForReplication
        }
    }

    function Pop-Migration
    {
        Remove-Table Foobar
    }

'@ | New-TestMigration -Name 'CreateBigIntWithIdentityNotForReplication'

        Invoke-RTRivet -Push 'CreateBigIntWithIdentityNotForReplication'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -NotForReplication
    }

    It 'should create big int with identity custom seed custom increment' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            BigInt ID -Identity -NotForReplication -Seed 4 -Increment 4
        }
    }

    function Pop-Migration
    {
        Remove-Table Foobar
    }

'@ | New-TestMigration -Name 'CreateBigIntWithIdentityCustomSeedCustomIncrement'

        Invoke-RTRivet -Push 'CreateBigIntWithIdentityCustomSeedCustomIncrement'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -NotNull -Seed 4 -Increment 4 -NotForReplication
    }

    It 'should create big int with custom value custom description' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            BigInt ID -Default 21 -Description 'Test'
        }
    }

    function Pop-Migration
    {
        Remove-Table Foobar
    }

'@ | New-TestMigration -Name 'CreateBigIntWithCustomValueCustomDescription'

        Invoke-RTRivet -Push 'CreateBigIntWithCustomValueCustomDescription'

        Assert-Table 'Foobar'
        Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -Default 21 -Description 'Test'
    }

    It 'should escape names' {
        @'
    function Push-Migration
    {
        Add-Schema 'New-BigInt'
        Add-Table 'Foo-Bar' -SchemaName 'New-BigInt' {
            BigInt 'ID-ID' -Default 21
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foo-Bar' -SchemaName 'New-BigInt'
        Remove-Schema 'New-BigInt'
    }

'@ | New-TestMigration -Name 'ShouldEscapeNames'

        Invoke-RTRivet -Push 'ShouldEscapeNames'

        Assert-Table 'Foo-Bar' -SchemaName 'New-BigInt'
        Assert-Column -Name 'ID-ID' -DataType 'BigInt' -TableName 'Foo-Bar' -SchemaName 'New-BigInt' -Default 21

    }
}
