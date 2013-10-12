
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
    Remove-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'RemoveDefaultConstraint'
    Invoke-Rivet -Push 'RemoveDefaultConstraint'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -TestNoDefault

}