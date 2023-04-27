
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldEnableCheckConstraint
{
    @'
function Push-Migration()
{
    Add-Table 'Migrations' -Column {
        Int 'Example' -NotNull
    }

    Add-CheckConstraint 'Migrations' 'CK_Migrations_Example' 'Example > 0'
    Disable-CheckConstraint 'Migrations' 'CK_Migrations_Example'
    Enable-CheckConstraint 'Migrations' 'CK_Migrations_Example'
}

function Pop-Migration()
{
    Remove-Table 'Migrations'
}
'@ | New-TestMigration -Name 'EnabledCheckConstraint'

    Invoke-RTRivet -Push 'EnabledCheckConstraint'
    Assert-CheckConstraint 'CK_Migrations_Example' -Definition '([Example]>(0))'
}

#trying to re-enable when a row violates the constraint causes error