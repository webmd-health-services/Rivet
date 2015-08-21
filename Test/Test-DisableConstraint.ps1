
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldDisableCheckConstraint
{
    @'
function Push-Migration()
{
    Add-Table 'Migrations' -Column {
        Int 'Example' -NotNull
    }

    Add-CheckConstraint 'Migrations' 'CK_Migrations_Example' 'Example > 0'
    Disable-Constraint 'Migrations' 'CK_Migrations_Example'

    # Will fail if Check Constraint is enabled
    Add-Row 'Migrations' @( @{ Example = -1 } )
}

function Pop-Migration()
{
    Remove-Table 'Migrations'
}
'@ | New-Migration -Name 'DisabledCheckConstraint'

    Invoke-RTRivet -Push 'DisabledCheckConstraint'
    Assert-CheckConstraint 'CK_Migrations_Example' -Definition '([Example]>(0))' -IsDisabled

    $row = Get-Row -SchemaName 'dbo' -TableName 'Migrations'
    Assert-Equal -1 $row.Example
}
