
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
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
    Remove-Table 'Migrations'
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
    Remove-Table 'Migrations'
}
'@ | New-Migration -Name 'AddCheckConstraint'

    Invoke-Rivet -Push 'AddCheckConstraint'
    Assert-CheckConstraint 'CK_Migrations_Example' -NotForReplication -Definition '([Example]>(0))'
}

function Test-ShouldAddCheckConstraintWithNoCheck
{
    @'
function Push-Migration()
{
    Add-Table 'Migrations' -Column {
        Int 'Example' -NotNull
    }

    Add-Row 'Migrations' @( @{ Example = -1 } )

    # Will fail without NOCHECK constraint
    Add-CheckConstraint 'Migrations' 'CK_Migrations_Example' 'Example > 0' -NoCheck
}

function Pop-Migration()
{
    Remove-Table 'Migrations'
}
'@ | New-Migration -Name 'AddCheckConstraint'

    Invoke-Rivet -Push 'AddCheckConstraint'

    $row = Get-Row -SchemaName 'dbo' -TableName 'Migrations'
    Assert-Equal -1 $row.Example

    Assert-CheckConstraint 'CK_Migrations_Example' -Definition '([Example]>(0))'
}