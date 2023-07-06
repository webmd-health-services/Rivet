
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Remove-CheckConstraint' {
    BeforeEach { Start-RivetTest }
    AfterEach { Stop-RivetTest }

    It 'should remove check constraint' {
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
'@ | New-TestMigration -Name 'RemoveCheckConstraint'

        Invoke-RTRivet -Push 'RemoveCheckConstraint'
        $CheckConstraints = Invoke-RivetTestQuery -Query 'select * from sys.check_constraints'

        'CK_rivet_Activity_Operation' | Should -Be $CheckConstraints[0].name
    }
}
