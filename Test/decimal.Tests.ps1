
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) 

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateDecimal
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID 
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateDecimalWithNullable'

    Invoke-RTRivet -Push 'CreateDecimalWithNullable'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -Precision 18 -Scale 0
}

function Test-ShouldCreateDecimalWithNullable
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID 5 2
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateDecimalWithNullable'

    Invoke-RTRivet -Push 'CreateDecimalWithNullable'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -Precision 5 -Scale 2
}

function Test-ShouldCreateDecimalWithNotNull
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID -NotNull 5 2
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateDecimalWithNotNull'

    Invoke-RTRivet -Push 'CreateDecimalWithNotNull'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -NotNull -Precision 5 -Scale 2
}

function Test-ShouldCreateDecimalWithSparse
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID -Sparse 5 2
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateDecimalWithSparse'

    Invoke-RTRivet -Push 'CreateDecimalWithSparse'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -Sparse -Precision 5 -Scale 2
}

function Test-ShouldCreateDecimalWithIdentity
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID 5 -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateDecimalWithIdentity'

    Invoke-RTRivet -Push 'CreateDecimalWithIdentity'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -Precision 5 -Scale 0
}

function Test-ShouldCreateDecimalWithIdentityNotForReplication
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID 5 -Identity -NotForReplication 
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateDecimalWithIdentityNotForReplication'

    Invoke-RTRivet -Push 'CreateDecimalWithIdentityNotForReplication'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -NotForReplication -Precision 5
}

function Test-ShouldCreateDecimalWithIdentityCustomSeedCustomIncrement
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID 5 -Identity -NotForReplication -Seed 4 -Increment 4
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateDecimalWithIdentityCustomSeedCustomIncrement'

    Invoke-RTRivet -Push 'CreateDecimalWithIdentityCustomSeedCustomIncrement'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -NotNull -Seed 4 -Increment 4 -NotForReplication -Precision 5
}

function Test-ShouldCreateDecimalWithCustomValueCustomDescription
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID  -Default 21 -Description 'Test' -Precision 5 -Scale 2
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateDecimalWithCustomValueCustomDescription'

    Invoke-RTRivet -Push 'CreateDecimalWithCustomValueCustomDescription'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -Default 21 -Description 'Test' -Precision 5 -Scale 2
}
