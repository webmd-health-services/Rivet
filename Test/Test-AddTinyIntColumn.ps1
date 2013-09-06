function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddTinyIntColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateTinyIntColumnNonDataTypeSpecific
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        New-Column 'id' -TinyInt -Identity
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateTinyIntColumnNonDataTypeSpecific'

    Invoke-Rivet -Push 'CreateTinyIntColumnNonDataTypeSpecific'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'TinyInt' -TableName 'Foobar' -NotNull
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
    
}

'@ | New-Migration -Name 'CreateTinyIntWithNullable'

    Invoke-Rivet -Push 'CreateTinyIntWithNullable'

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
    
}

'@ | New-Migration -Name 'CreateTinyIntWithNotNull'

    Invoke-Rivet -Push 'CreateTinyIntWithNotNull'

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
    
}

'@ | New-Migration -Name 'CreateTinyIntWithSparse'

    Invoke-Rivet -Push 'CreateTinyIntWithSparse'

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
    
}

'@ | New-Migration -Name 'CreateTinyIntWithIdentity'

    Invoke-Rivet -Push 'CreateTinyIntWithIdentity'

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
    
}

'@ | New-Migration -Name 'CreateTinyIntWithIdentityNotForReplication'

    Invoke-Rivet -Push 'CreateTinyIntWithIdentityNotForReplication'

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
    
}

'@ | New-Migration -Name 'CreateTinyIntWithIdentityCustomSeedCustomIncrement'

    Invoke-Rivet -Push 'CreateTinyIntWithIdentityCustomSeedCustomIncrement'

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
    
}

'@ | New-Migration -Name 'CreateTinyIntWithCustomValueCustomDescription'

    Invoke-Rivet -Push 'CreateTinyIntWithCustomValueCustomDescription'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'TinyInt' -TableName 'Foobar' -Default 21 -Description 'Test'
}