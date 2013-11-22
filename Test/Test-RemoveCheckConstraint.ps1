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
}
'@ | New-Migration -Name 'RemoveCheckConstraint'

    Invoke-Rivet -Push 'RemoveCheckConstraint'
    $CheckConstraints = Invoke-RivetTestQuery -Query 'select * from sys.check_constraints'

    Assert-Equal $CheckConstraints[0].name CK_rivet_Activity_Operation
}
