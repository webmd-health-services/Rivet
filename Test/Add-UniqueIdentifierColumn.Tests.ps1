
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-UniqueIdentifierColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create unique identifier column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            UniqueIdentifier 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateUniqueIdentifierColumn'

        Invoke-RTRivet -Push 'CreateUniqueIdentifierColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'UniqueIdentifier' -TableName 'Foobar'
    }

    It 'should create unique identifier column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            UniqueIdentifier 'id' -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateUniqueIdentifierColumnWithSparse'

        Invoke-RTRivet -Push 'CreateUniqueIdentifierColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'UniqueIdentifier' -TableName 'Foobar' -Sparse
    }

    It 'should create unique identifier column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            UniqueIdentifier 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateUniqueIdentifierColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateUniqueIdentifierColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'UniqueIdentifier' -TableName 'Foobar' -NotNull
    }

    It 'should create unique identifier row guid col' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            UniqueIdentifier 'id' -NotNull -RowGuidCol
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateUniqueIdentifierRowGuidCol'

        Invoke-RTRivet -Push 'CreateUniqueIdentifierRowGuidCol'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'UniqueIdentifier' -TableName 'Foobar' -NotNull -RowGuidCol
    }
}
