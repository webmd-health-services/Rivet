
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRemoveDefaultConstraint
{
    @"
function Push-Migration()
{
    Add-Table -Name 'AddDefaultConstraint' {
        Int 'DefaultConstraintMe' -NotNull
    }

    Add-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101
    Remove-DefaultConstraint 'AddDefaultConstraint' -Name '$(New-ConstraintName -Default 'AddDefaultConstraint' 'DefaultConstraintMe')'
}

function Pop-Migration()
{
    Remove-Table 'AddDefaultConstraint'
}
"@ | New-TestMigration -Name 'RemoveDefaultConstraint'
    Invoke-RTRivet -Push 'RemoveDefaultConstraint'
    Assert-Null (Get-DefaultConstraint 'DF_AddDefaultConstraint_DefaultConstraintMe')
}

function Test-ShouldQuoteDefaultConstraintName
{
    @"
function Push-Migration()
{
    Add-Table -Name 'Remove-DefaultConstraint' {
        Int 'DefaultConstraintMe' -NotNull
    }

    Add-DefaultConstraint -TableName 'Remove-DefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101
    Remove-DefaultConstraint -TableName 'Remove-DefaultConstraint' -Name '$(New-ConstraintName -Default 'Remove-DefaultConstraint' 'DefaultConstraintMe')'
}

function Pop-Migration()
{
    Remove-Table 'Remove-DefaultConstraint'
}
"@ | New-TestMigration -Name 'RemoveDefaultConstraint'
    Invoke-RTRivet -Push 'RemoveDefaultConstraint'
    Assert-Null (Get-DefaultConstraint 'DF_Remove-DefaultConstraint_DefaultConstraintMe')
}


function Test-ShouldRemoveDefaultConstraintWithDefaultName
{
    @"
function Push-Migration()
{
    Add-Table -Name 'AddDefaultConstraint' {
        Int 'DefaultConstraintMe' -NotNull
    }

    Add-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101
    Remove-DefaultConstraint 'AddDefaultConstraint' 'DefaultConstraintMe'
}

function Pop-Migration()
{
    Remove-Table 'AddDefaultConstraint'
}
"@ | New-TestMigration -Name 'RemoveDefaultConstraint'
    Invoke-RTRivet -Push 'RemoveDefaultConstraint'
    Assert-Null (Get-DefaultConstraint 'DF_AddDefaultConstraint_DefaultConstraintMe')
}
