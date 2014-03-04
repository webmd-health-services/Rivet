function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldAddCheckConstraint
{
    @'
function Push-Migration()
{
    Add-Table 'Migrations' -Column {
        Int 'Example' -NotNull
    }

    Add-CheckConstraint 'Migrations' 'CK_Migrations_Example' 'Example > 0'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'AddCheckConstraint'

    Invoke-Rivet -Push 'AddCheckConstraint'
    Assert-CheckConstraint 'CK_Migrations_Example' -Definition '([Example]>(0))'
}

function Test-ShouldAddCheckConstraintWithNoReplication
{
    @'
function Push-Migration()
{
    Add-Table 'Migrations' -Column {
        Int 'Example' -NotNull
    }

    Add-CheckConstraint 'Migrations' 'CK_Migrations_Example' 'Example > 0' -NotForReplication
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'AddCheckConstraint'

    Invoke-Rivet -Push 'AddCheckConstraint'
    Assert-CheckConstraint 'CK_Migrations_Example' -NotForReplication -Definition '([Example]>(0))'
}