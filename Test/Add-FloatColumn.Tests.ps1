
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-FloatColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create float column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Float 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateFloatColumn'

        Invoke-RTRivet -Push 'CreateFloatColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Float' -TableName 'Foobar' -Precision 53
    }

    It 'should create float column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Float 'id' 3 -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateFloatColumnWithSparse'

        Invoke-RTRivet -Push 'CreateFloatColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'real' -TableName 'Foobar' -Sparse -Precision 24
    }

    It 'should create float column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Float 'id' 33 -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateFloatColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateFloatColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Float' -TableName 'Foobar' -NotNull -Precision 53
    }
}
