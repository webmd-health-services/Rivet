
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-HierarchyIDColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create hierarchy i d column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            HierarchyID 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateHierarchyIDColumn'

        Invoke-RTRivet -Push 'CreateHierarchyIDColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'HierarchyID' -TableName 'Foobar'
    }

    It 'should create hierarchy i d column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            HierarchyID 'id' -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateHierarchyIDColumnWithSparse'

        Invoke-RTRivet -Push 'CreateHierarchyIDColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'HierarchyID' -TableName 'Foobar' -Sparse
    }

    It 'should create hierarchy i d column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            HierarchyID 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateHierarchyIDColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateHierarchyIDColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'HierarchyID' -TableName 'Foobar' -NotNull
    }
}
