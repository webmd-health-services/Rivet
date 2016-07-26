
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateSmallIntWithNullable
{
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

function Test-ShouldCreateSmallIntWithNotNull
{
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

function Test-ShouldCreateSmallIntWithSparse
{
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

function Test-ShouldCreateSmallIntWithIdentity
{
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

function Test-ShouldCreateSmallIntWithIdentityNotForReplication
{
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

function Test-ShouldCreateSmallIntWithIdentityCustom
{
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

function Test-ShouldCreateSmallIntWithCustomValueCustomDescription
{
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
