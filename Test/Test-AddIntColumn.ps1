function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddIntColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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
    
}

'@ | New-Migration -Name 'CreateIntWithNullable'

    Invoke-Rivet -Push 'CreateIntWithNullable'

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
    
}

'@ | New-Migration -Name 'CreateIntWithNotNull'

    Invoke-Rivet -Push 'CreateIntWithNotNull'

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
    
}

'@ | New-Migration -Name 'CreateIntWithSparse'

    Invoke-Rivet -Push 'CreateIntWithSparse'

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
    
}

'@ | New-Migration -Name 'CreateIntWithIdentity'

    Invoke-Rivet -Push 'CreateIntWithIdentity'

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
    
}

'@ | New-Migration -Name 'CreateIntWithIdentityNotForReplication'

    Invoke-Rivet -Push 'CreateIntWithIdentityNotForReplication'

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
    
}

'@ | New-Migration -Name 'CreateIntWithIdentityCustomSeedCustomIncrement'

    Invoke-Rivet -Push 'CreateIntWithIdentityCustomSeedCustomIncrement'

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
    
}

'@ | New-Migration -Name 'CreateIntWithCustomValueCustomDescription'

    Invoke-Rivet -Push 'CreateIntWithCustomValueCustomDescription'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Int' -TableName 'Foobar' -Default 21 -Description 'Test'
}