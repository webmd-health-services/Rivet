
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Redo-Migration' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should pop then push top migration' {
        @'
    function Push-Migration()
    {
        Add-Table 'RedoMigration' {
            Int 'id' -Identity
        }
    }

    function Pop-Migration()
    {
        Remove-Table 'RedoMigration'
    }
'@ | New-TestMigration -Name 'CreateTable'

        @'
    function Push-Migration()
    {
        Update-Table -Name 'RedoMigration' -AddColumn {
            Varchar 'description' -Max
        }

        Add-Table 'SecondTable' {
            Int 'id' -Identity
        }
    }

    function Pop-Migration()
    {
        Remove-Table 'SecondTable'

        Update-Table 'RedoMigration' -Remove 'description'
    }
'@ | New-TestMigration -Name 'AddColumn'

        Invoke-RTRivet -Push

        $redoMigrationTable = Get-Table -Name 'RedoMigration'
        $secondTable = Get-Table -Name 'SecondTable'

        $migrationInfo = Get-MigrationInfo -Name 'AddColumn'
        $migrationInfo | Should -Not -BeNullOrEmpty

        Invoke-RTRivet -Redo

        # Make sure only one migration was popped/pushed.
        $redoMigrationTableRedo = Get-Table -Name 'RedoMigration'
        $redoMigrationTableRedo.create_date | Should -Be $redoMigrationTable.create_date

        $secondTableRedo = Get-Table -Name 'SecondTable'
        $secondTableRedo | Should -Not -BeNullOrEmpty
        ($redoMigrationTable.create_date -lt $secondTableRedo.create_date) | Should -BeTrue

        $redoMigrationInfo = Get-MigrationInfo -Name 'AddColumn'
        $redoMigrationInfo | Should -Not -BeNullOrEmpty
        ($migrationInfo.AtUtc -lt $redoMigrationInfo.AtUtc) | Should -BeTrue
    }
}
