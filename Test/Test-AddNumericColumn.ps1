function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddNumericColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateNumericWithNullable
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Numeric ID -Precision 5 -Scale 2
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNumericWithNullable'

    Invoke-Rivet -Push 'CreateNumericWithNullable'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Numeric' -TableName 'Foobar' -Precision 5 -Scale 2
}

function Test-ShouldCreateNumericWithNotNull
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Numeric ID -NotNull -Precision 5 -Scale 2
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNumericWithNotNull'

    Invoke-Rivet -Push 'CreateNumericWithNotNull'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Numeric' -TableName 'Foobar' -NotNull -Precision 5 -Scale 2
}

function Test-ShouldCreateNumericWithSparse
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Numeric ID -Sparse -Precision 5 -Scale 2
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNumericWithSparse'

    Invoke-Rivet -Push 'CreateNumericWithSparse'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Numeric' -TableName 'Foobar' -Sparse -Precision 5 -Scale 2
}

function Test-ShouldCreateNumericWithIdentity
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Numeric ID -Identity -Precision 5
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNumericWithIdentity'

    Invoke-Rivet -Push 'CreateNumericWithIdentity'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Numeric' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -Precision 5
}

function Test-ShouldCreateNumericWithIdentityNotForReplication
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Numeric ID -Identity -NotForReplication -Precision 5
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNumericWithIdentityNotForReplication'

    Invoke-Rivet -Push 'CreateNumericWithIdentityNotForReplication'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Numeric' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -NotForReplication -Precision 5
}

function Test-ShouldCreateNumericWithIdentityCustomSeedCustomIncrement
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Numeric ID -Identity -NotForReplication -Seed 4 -Increment 4 -Precision 5
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNumericWithIdentityCustomSeedCustomIncrement'

    Invoke-Rivet -Push 'CreateNumericWithIdentityCustomSeedCustomIncrement'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Numeric' -TableName 'Foobar' -NotNull -Seed 4 -Increment 4 -NotForReplication -Precision 5
}

function Test-ShouldCreateNumericWithCustomValueCustomDescription
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Numeric ID  -Default 21 -Description 'Test' -Precision 5 -Scale 2
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNumericWithCustomValueCustomDescription'

    Invoke-Rivet -Push 'CreateNumericWithCustomValueCustomDescription'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Numeric' -TableName 'Foobar' -Default 21 -Description 'Test' -Precision 5 -Scale 2
}