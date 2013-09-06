function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddBigIntColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateBigIntColumnNonDataTypeSpecific
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        New-Column 'id' -BigInt -Identity
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateBigIntColumnNonDataTypeSpecific'

    Invoke-Rivet -Push 'CreateBigIntColumnNonDataTypeSpecific'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'BigInt' -TableName 'Foobar' -NotNull
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
    
}

'@ | New-Migration -Name 'CreateBigIntWithCustomValueCustomDescription'

    Invoke-Rivet -Push 'CreateBigIntWithCustomValueCustomDescription'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'BigInt' -TableName 'Foobar' -Default 21 -Description 'Test'
}