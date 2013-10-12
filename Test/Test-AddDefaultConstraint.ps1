
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

function Test-ShouldAddDefaultConstraint
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
}
'@ | New-Migration -Name 'AddDefaultConstraint'

    Invoke-Rivet -Push 'AddDefaultConstraint'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe'

}

function Test-ShouldAddDefaultConstraintWithValues
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddDefaultConstraint' {
        Int 'DefaultConstraintMe' -NotNull
    }

    Add-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101 -WithValues
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'AddDefaultConstraintWithValues'

    $Error.Clear()
    Invoke-Rivet -Push 'AddDefaultConstraintWithValues'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe'
    Assert-Equal 0 $Error.Count
}