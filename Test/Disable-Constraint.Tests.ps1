
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Disable-Constraint' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should disable check constraint' {
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
'@ | New-TestMigration -Name 'DisabledCheckConstraint'

        Invoke-RTRivet -Push 'DisabledCheckConstraint'
        Assert-CheckConstraint 'CK_Migrations_Example' -Definition '([Example]>(0))' -IsDisabled

        $row = Get-Row -SchemaName 'dbo' -TableName 'Migrations'
        $row.Example | Should -Be -1
    }
}
