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
    $CheckConstraints = Invoke-RivetTestQuery -Query 'select * from sys.check_constraints'

    Assert-Equal 'CK_MIgrations_Example' $CheckConstraints.name
    Assert-False $CheckConstraints.is_not_for_replication
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
    $CheckConstraints = Invoke-RivetTestQuery -Query 'select * from sys.check_constraints'

    Assert-Equal 'CK_MIgrations_Example' $CheckConstraints.name
    Assert-True $CheckConstraints.is_not_for_replication
}