function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddSmallIntColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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
    
}

'@ | New-Migration -Name 'CreateSmallIntWithNullable'

    Invoke-Rivet -Push 'CreateSmallIntWithNullable'

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
    
}

'@ | New-Migration -Name 'CreateSmallIntWithNotNull'

    Invoke-Rivet -Push 'CreateSmallIntWithNotNull'

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
    
}

'@ | New-Migration -Name 'CreateSmallIntWithSparse'

    Invoke-Rivet -Push 'CreateSmallIntWithSparse'

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
    
}

'@ | New-Migration -Name 'CreateSmallIntWithIdentity'

    Invoke-Rivet -Push 'CreateSmallIntWithIdentity'

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
    
}

'@ | New-Migration -Name 'CreateSmallIntWithIdentityNotForReplication'

    Invoke-Rivet -Push 'CreateSmallIntWithIdentityNotForReplication'

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
    
}

'@ | New-Migration -Name 'CreateSmallIntWithIdentityCustom'

    Invoke-Rivet -Push 'CreateSmallIntWithIdentityCustom'

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
    
}

'@ | New-Migration -Name 'CreateSmallIntWithCustomValueCustomDescription'

    Invoke-Rivet -Push 'CreateSmallIntWithCustomValueCustomDescription'

    Assert-Table 'Foobar'
    Assert-Column -Name 'ID' -DataType 'SmallInt' -TableName 'Foobar' -Default 21 -Description 'Test'
}