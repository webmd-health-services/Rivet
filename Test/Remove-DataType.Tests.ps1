
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Remove-DataType' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should remove data type by table' {
        # Yes.  Spaces in names so we check that the names get quoted.
        @'
function Push-Migration
{
    Add-DataType 'Users DT' -AsTable { varchar 'Name' 50 } -TableConstraint 'primary key'
}

function Pop-Migration
{
    Remove-DataType 'Users DT'
}

'@ | New-TestMigration -Name 'ByTable'

        Invoke-RTRivet -Push 'ByTable'

        $temp = Invoke-RivetTestQuery -Query 'select * from sys.table_types'
            $temp | Should -Not -BeNullOrEmpty
            'Users DT' | Should -Be $temp.name

        Invoke-RTRivet -Pop 1
        $temp = Invoke-RivetTestQuery -Query 'select * from sys.table_types'
            $temp | Should -BeNullOrEmpty
    }
}
