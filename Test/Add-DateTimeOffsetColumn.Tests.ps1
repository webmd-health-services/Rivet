
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-DateTimeOffsetColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create date time offset column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTimeOffset 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateTimeOffsetColumn'

        Invoke-RTRivet -Push 'CreateDateTimeOffsetColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'DateTimeOffset' -TableName 'Foobar' -Scale 7
    }

    It 'should create date time offset column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTimeOffset 'id' 6 -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateTimeOffsetColumnWithSparse'

        Invoke-RTRivet -Push 'CreateDateTimeOffsetColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'DateTimeOffset' -TableName 'Foobar' -Sparse -Scale 6
    }

    It 'should create date time offset column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTimeOffset 'id' 6 -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateTimeOffsetColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateDateTimeOffsetColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'DateTimeOffset' -TableName 'Foobar' -NotNull -Scale 6
    }

    It 'should create date time offset column with no precision' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTimeOffset 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'ShouldCreateDateTimeOffsetColumnWithNoPrecision'

        Invoke-RTRivet -Push 'ShouldCreateDateTimeOffsetColumnWithNoPrecision'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'DateTimeOffset' -TableName 'Foobar' -NotNull -Scale 7
    }
}
