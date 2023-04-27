
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-CheckConstraint' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should add check constraint' {
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
'@ | New-TestMigration -Name 'AddCheckConstraint'

        Invoke-RTRivet -Push 'AddCheckConstraint'
        Assert-CheckConstraint 'CK_Migrations_Example' -Definition '([Example]>(0))'
    }

    It 'should add check constraint with no replication' {
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
'@ | New-TestMigration -Name 'AddCheckConstraint'

        Invoke-RTRivet -Push 'AddCheckConstraint'
        Assert-CheckConstraint 'CK_Migrations_Example' -NotForReplication -Definition '([Example]>(0))'
    }

    It 'should add check constraint with no check' {
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
'@ | New-TestMigration -Name 'AddCheckConstraint'

        Invoke-RTRivet -Push 'AddCheckConstraint'

        $row = Get-Row -SchemaName 'dbo' -TableName 'Migrations'
        $row.Example | Should -Be -1

        Assert-CheckConstraint 'CK_Migrations_Example' -Definition '([Example]>(0))'
    }
}
