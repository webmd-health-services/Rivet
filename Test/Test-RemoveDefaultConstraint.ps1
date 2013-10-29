
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
    Remove-DefaultConstraint 'AddDefaultConstraint' 'DefaultConstraintMe'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'RemoveDefaultConstraint'
    Invoke-Rivet -Push 'RemoveDefaultConstraint'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -TestNoDefault

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
}
'@ | New-Migration -Name 'RemoveDefaultConstraint'
    Invoke-Rivet -Push 'RemoveDefaultConstraint'
    Assert-DefaultConstraint -TableName 'Remove-DefaultConstraint' -ColumnName 'DefaultConstraintMe' -TestNoDefault

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
    Remove-DefaultConstraint 'AddDefaultConstraint' 'DefaultConstraintMe' -Name 'Optional'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'RemoveDefaultConstraintWithOptionalConstraintName'
    Invoke-Rivet -Push 'RemoveDefaultConstraintWithOptionalConstraintName'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -TestNoDefault

}