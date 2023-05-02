
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-RealColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create real column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Real 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateRealColumn'

        Invoke-RTRivet -Push 'CreateRealColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Real' -TableName 'Foobar'
    }

    It 'should create real column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Real 'id' -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateRealColumnWithSparse'

        Invoke-RTRivet -Push 'CreateRealColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Real' -TableName 'Foobar' -Sparse
    }

    It 'should create real column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Real 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateRealColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateRealColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Real' -TableName 'Foobar' -NotNull
    }
}
