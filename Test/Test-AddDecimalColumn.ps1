function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddDecimalColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}


function Test-ShouldCreateDecimalWithNullable
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID -Precision 5 -Scale 2
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDecimalWithNullable'

    Invoke-Rivet -Push 'CreateDecimalWithNullable'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -Precision 5 -Scale 2
}

function Test-ShouldCreateDecimalWithNotNull
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID -NotNull -Precision 5 -Scale 2
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDecimalWithNotNull'

    Invoke-Rivet -Push 'CreateDecimalWithNotNull'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -NotNull -Precision 5 -Scale 2
}

function Test-ShouldCreateDecimalWithSparse
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID -Sparse -Precision 5 -Scale 2
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDecimalWithSparse'

    Invoke-Rivet -Push 'CreateDecimalWithSparse'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -Sparse -Precision 5 -Scale 2
}

function Test-ShouldCreateDecimalWithIdentity
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID -Identity -Precision 5
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDecimalWithIdentity'

    Invoke-Rivet -Push 'CreateDecimalWithIdentity'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -Precision 5
}

function Test-ShouldCreateDecimalWithIdentityNotForReplication
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID -Identity -NotForReplication -Precision 5
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDecimalWithIdentityNotForReplication'

    Invoke-Rivet -Push 'CreateDecimalWithIdentityNotForReplication'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -NotNull -Seed 1 -Increment 1 -NotForReplication -Precision 5
}

function Test-ShouldCreateDecimalWithIdentityCustomSeedCustomIncrement
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Decimal ID -Identity -NotForReplication -Seed 4 -Increment 4 -Precision 5
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDecimalWithIdentityCustomSeedCustomIncrement'

    Invoke-Rivet -Push 'CreateDecimalWithIdentityCustomSeedCustomIncrement'

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
    
}

'@ | New-Migration -Name 'CreateDecimalWithCustomValueCustomDescription'

    Invoke-Rivet -Push 'CreateDecimalWithCustomValueCustomDescription'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'Decimal' -TableName 'Foobar' -Default 21 -Description 'Test' -Precision 5 -Scale 2
}