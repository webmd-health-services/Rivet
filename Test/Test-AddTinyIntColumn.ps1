
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateTinyIntWithNullable
{
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

'@ | New-Migration -Name 'CreateTinyIntWithNullable'

    Invoke-RTRivet -Push 'CreateTinyIntWithNullable'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar'
}

function Test-ShouldCreateTinyIntWithNotNull
{
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

'@ | New-Migration -Name 'CreateTinyIntWithNotNull'

    Invoke-RTRivet -Push 'CreateTinyIntWithNotNull'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -NotNull
}

function Test-ShouldCreateTinyIntWithSparse
{
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

'@ | New-Migration -Name 'CreateTinyIntWithSparse'

    Invoke-RTRivet -Push 'CreateTinyIntWithSparse'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateTinyIntWithIdentity
{
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

'@ | New-Migration -Name 'CreateTinyIntWithIdentity'

    Invoke-RTRivet -Push 'CreateTinyIntWithIdentity'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1
}

function Test-ShouldCreateTinyIntWithIdentityNotForReplication
{
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

'@ | New-Migration -Name 'CreateTinyIntWithIdentityNotForReplication'

    Invoke-RTRivet -Push 'CreateTinyIntWithIdentityNotForReplication'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -NotForReplication
}

function Test-ShouldCreateTinyIntWithIdentityCustomSeedCustomIncrement
{
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

'@ | New-Migration -Name 'CreateTinyIntWithIdentityCustomSeedCustomIncrement'

    Invoke-RTRivet -Push 'CreateTinyIntWithIdentityCustomSeedCustomIncrement'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -NotNull -Seed 4 -Increment 4 -NotForReplication
}

function Test-ShouldCreateTinyIntWithCustomValueCustomDescription
{
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

'@ | New-Migration -Name 'CreateTinyIntWithCustomValueCustomDescription'

    Invoke-RTRivet -Push 'CreateTinyIntWithCustomValueCustomDescription'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -Default 21 -Description 'Test'
}
