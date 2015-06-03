
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateIntWithNullable
{
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

'@ | New-Migration -Name 'CreateIntWithNullable'

    Invoke-RTRivet -Push 'CreateIntWithNullable'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar'
}

function Test-ShouldCreateIntWithNotNull
{
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

'@ | New-Migration -Name 'CreateIntWithNotNull'

    Invoke-RTRivet -Push 'CreateIntWithNotNull'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -NotNull
}

function Test-ShouldCreateIntWithSparse
{
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

'@ | New-Migration -Name 'CreateIntWithSparse'

    Invoke-RTRivet -Push 'CreateIntWithSparse'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateIntWithIdentity
{
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

'@ | New-Migration -Name 'CreateIntWithIdentity'

    Invoke-RTRivet -Push 'CreateIntWithIdentity'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1
}

function Test-ShouldCreateIntWithIdentityNotForReplication
{
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

'@ | New-Migration -Name 'CreateIntWithIdentityNotForReplication'

    Invoke-RTRivet -Push 'CreateIntWithIdentityNotForReplication'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -NotForReplication
}

function Test-ShouldCreateIntWithIdentityCustomSeedCustomIncrement
{
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

'@ | New-Migration -Name 'CreateIntWithIdentityCustomSeedCustomIncrement'

    Invoke-RTRivet -Push 'CreateIntWithIdentityCustomSeedCustomIncrement'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -NotNull -Seed 4 -Increment 4 -NotForReplication
}

function Test-ShouldCreateIntWithCustomValueCustomDescription
{
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

'@ | New-Migration -Name 'CreateIntWithCustomValueCustomDescription'

    Invoke-RTRivet -Push 'CreateIntWithCustomValueCustomDescription'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -Default 21 -Description 'Test'
}
