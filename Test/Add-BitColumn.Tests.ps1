
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-BitColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create bit column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Bit 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateBitColumn'

        Invoke-RTRivet -Push 'CreateBitColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Bit' -TableName 'Foobar'
    }

    It 'should create bit column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Bit 'id' -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateBitColumnWithSparse'

        Invoke-RTRivet -Push 'CreateBitColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Bit' -TableName 'Foobar' -Sparse
    }

    It 'should create bit column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Bit 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateBitColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateBitColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Bit' -TableName 'Foobar' -NotNull
    }
}
