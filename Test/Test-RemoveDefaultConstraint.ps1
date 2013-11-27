
function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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
}

function Pop-Migration()
{
    Remove-DefaultConstraint 'AddDefaultConstraint' 'DefaultConstraintMe'
}
'@ | New-Migration -Name 'RemoveDefaultConstraint'
    Invoke-Rivet -Push 'RemoveDefaultConstraint'
    Assert-NotNull (Get-DefaultConstraint 'DF_AddDefaultConstraint_DefaultConstraintMe')

    Invoke-Rivet -Pop 1
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
}

function Pop-Migration()
{
    Remove-DefaultConstraint -TableName 'Remove-DefaultConstraint' -ColumnName 'DefaultConstraintMe'
}
'@ | New-Migration -Name 'RemoveDefaultConstraint'
    Invoke-Rivet -Push 'RemoveDefaultConstraint'
    Assert-NotNull (Get-DefaultConstraint 'DF_Remove-DefaultConstraint_DefaultConstraintMe')

    Invoke-Rivet -Pop 1
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
}

function Pop-Migration()
{
    Remove-DefaultConstraint 'AddDefaultConstraint' -Name 'Optional'
}
'@ | New-Migration -Name 'RemoveDefaultConstraintWithOptionalConstraintName'
    Invoke-Rivet -Push 'RemoveDefaultConstraintWithOptionalConstraintName'
    Assert-NotNull (Get-DefaultConstraint -Name 'Optional')

    Invoke-Rivet -Pop 1
    Assert-Null (Get-DefaultConstraint -Name 'Optional')
}