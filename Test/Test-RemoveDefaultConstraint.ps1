
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
    @'
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
'@ | New-Migration -Name 'RemoveDefaultConstraint'
    Invoke-Rivet -Push 'RemoveDefaultConstraint'
    Assert-Null (Get-DefaultConstraint 'DF_AddDefaultConstraint_DefaultConstraintMe')
}

function Test-ShouldQuoteDefaultConstraintName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Remove-DefaultConstraint' {
        Int 'DefaultConstraintMe' -NotNull
    }

    Add-DefaultConstraint -TableName 'Remove-DefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101
    Remove-DefaultConstraint -TableName 'Remove-DefaultConstraint' -ColumnName 'DefaultConstraintMe'
}

function Pop-Migration()
{
    Remove-Table 'Remove-DefaultConstraint'
}
'@ | New-Migration -Name 'RemoveDefaultConstraint'
    Invoke-Rivet -Push 'RemoveDefaultConstraint'
    Assert-Null (Get-DefaultConstraint 'DF_Remove-DefaultConstraint_DefaultConstraintMe')

}

function Test-ShouldRemoveDefaultConstraintWithOptionalConstraintName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddDefaultConstraint' {
        Int 'DefaultConstraintMe' -NotNull
    }

    Add-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101 -Name 'Optional'
    Remove-DefaultConstraint 'AddDefaultConstraint' -Name 'Optional'
}

function Pop-Migration()
{
    Remove-Table 'AddDefaultConstraint'
}
'@ | New-Migration -Name 'RemoveDefaultConstraintWithOptionalConstraintName'
    Invoke-Rivet -Push 'RemoveDefaultConstraintWithOptionalConstraintName'
    Assert-Null (Get-DefaultConstraint -Name 'Optional')
}