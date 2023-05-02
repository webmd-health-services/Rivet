
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-TimeColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create time column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Time 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateTimeColumn'

        Invoke-RTRivet -Push 'CreateTimeColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Time' -TableName 'Foobar' -Scale 7
    }

    It 'should create time column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Time 'id' 3 -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateTimeColumnWithSparse'

        Invoke-RTRivet -Push 'CreateTimeColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Time' -TableName 'Foobar' -Sparse -Scale 3
    }

    It 'should create time column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Time 'id' 2 -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateTimeColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateTimeColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Time' -TableName 'Foobar' -NotNull -Scale 2
    }
}
