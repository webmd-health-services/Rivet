
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Enable-Constraint' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should enable check constraint' {
        @'
    function Push-Migration()
    {
        Add-Table 'Migrations' -Column {
            Int 'Example' -NotNull
        }

        Add-CheckConstraint 'Migrations' 'CK_Migrations_Example' 'Example > 0'
        Disable-Constraint 'Migrations' 'CK_Migrations_Example'
        Enable-Constraint 'Migrations' 'CK_Migrations_Example'
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
}
