
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-SmallDateTimeColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create small date time column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            SmallDateTime 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateSmallDateTimeColumn'

        Invoke-RTRivet -Push 'CreateSmallDateTimeColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'SmallDateTime' -TableName 'Foobar'
    }

    It 'should create small date time column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            SmallDateTime 'id' -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateSmallDateTimeColumnWithSparse'

        Invoke-RTRivet -Push 'CreateSmallDateTimeColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'SmallDateTime' -TableName 'Foobar' -Sparse
    }

    It 'should create small date time column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            SmallDateTime 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateSmallDateTimeColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateSmallDateTimeColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'SmallDateTime' -TableName 'Foobar' -NotNull
    }
}
