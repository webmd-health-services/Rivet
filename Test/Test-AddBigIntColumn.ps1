
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateBigIntWithNullable
{
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

'@ | New-Migration -Name 'CreateBigIntWithNullable'

    Invoke-Rivet -Push 'CreateBigIntWithNullable'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar'
}

function Test-ShouldCreateBigIntWithNotNull
{
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

'@ | New-Migration -Name 'CreateBigIntWithNotNull'

    Invoke-Rivet -Push 'CreateBigIntWithNotNull'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -NotNull
}

function Test-ShouldCreateBigIntWithSparse
{
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

'@ | New-Migration -Name 'CreateBigIntWithSparse'

    Invoke-Rivet -Push 'CreateBigIntWithSparse'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateBigIntWithIdentity
{
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

'@ | New-Migration -Name 'CreateBigIntWithIdentity'

    Invoke-Rivet -Push 'CreateBigIntWithIdentity'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1
}

function Test-ShouldCreateBigIntWithIdentityNotForReplication
{
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

'@ | New-Migration -Name 'CreateBigIntWithIdentityNotForReplication'

    Invoke-Rivet -Push 'CreateBigIntWithIdentityNotForReplication'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -NotForReplication
}

function Test-ShouldCreateBigIntWithIdentityCustomSeedCustomIncrement
{
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

'@ | New-Migration -Name 'CreateBigIntWithIdentityCustomSeedCustomIncrement'

    Invoke-Rivet -Push 'CreateBigIntWithIdentityCustomSeedCustomIncrement'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -NotNull -Seed 4 -Increment 4 -NotForReplication
}

function Test-ShouldCreateBigIntWithCustomValueCustomDescription
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        BigInt ID  -Default 21 -Description 'Test'
    }
}

function Pop-Migration
{
    Remove-Table Foobar    
}

'@ | New-Migration -Name 'CreateBigIntWithCustomValueCustomDescription'

    Invoke-Rivet -Push 'CreateBigIntWithCustomValueCustomDescription'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -Default 21 -Description 'Test'
}

function Test-ShouldEscapeNames
{
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

'@ | New-Migration -Name 'ShouldEscapeNames'

    Invoke-Rivet -Push 'ShouldEscapeNames'

    Assert-Table 'Foo-Bar' -SchemaName 'New-BigInt'
    Assert-Column -Name 'ID-ID' -DataType 'BigInt' -TableName 'Foo-Bar' -SchemaName 'New-BigInt' -Default 21 
    
}