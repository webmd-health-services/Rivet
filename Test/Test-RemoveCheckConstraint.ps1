
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRemoveCheckConstraint
{
    @'
function Push-Migration()
{
    Add-Table 'Migrations' -Column {
        Int 'Example' -NotNull
    }

    Add-CheckConstraint 'Migrations' 'CK_Migrations_Example' 'Example > 0'
    Remove-CheckConstraint 'Migrations' 'CK_Migrations_Example'
}

function Pop-Migration()
{
    Remove-Table 'Migrations'
}
'@ | New-Migration -Name 'RemoveCheckConstraint'

    Invoke-Rivet -Push 'RemoveCheckConstraint'
    $CheckConstraints = Invoke-RivetTestQuery -Query 'select * from sys.check_constraints'

    Assert-Equal $CheckConstraints[0].name CK_rivet_Activity_Operation
}
