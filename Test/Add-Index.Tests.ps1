
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Add-Index' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }


    It 'should add index with one column' {
        # Yes.  Spaces in the name so we check the name gets quoted.
        @'
    function Push-Migration()
    {

        Add-Table -Name 'Add Index' {
            Int 'Index Me' -NotNull
        }

        #Add an Index to 'IndexMe'
        Add-Index -TableName 'Add Index' -ColumnName 'Index Me'

    }

    function Pop-Migration()
    {
        Remove-Table 'Add Index'
    }
'@ | New-TestMigration -Name 'AddIndex'

        Invoke-RTRivet -Push 'AddIndex'

        ##Assert Table and Column
        (Test-Table 'Add Index') | Should -BeTrue
        (Test-Column -Name 'Index Me' -TableName 'Add Index') | Should -BeTrue

        ##Assert Index
        Assert-Index -TableName 'Add Index' -ColumnName 'Index Me'

    }

    It 'should add index with multiple columns' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
            Char 'IndexMe2' -Size 255 -NotNull
            Int 'DonotIndex' -NotNull
        }

        #Add an Index to 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName "IndexMe","IndexMe2"
    }

    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
'@ | New-TestMigration -Name 'AddIndexMultipleColumns'

        Invoke-RTRivet -Push 'AddIndexMultipleColumns'

        (Test-Table 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'IndexMe' -TableName 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'IndexMe2' -TableName 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'DoNotIndex' -TableName 'AddIndex') | Should -BeTrue

        ##Assert Index
        Assert-Index -TableName 'AddIndex' -ColumnName "IndexMe","IndexMe2"

    }

    It 'should create clustered index' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
        }

        #Add an Index to 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Clustered
    }

    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
'@ | New-TestMigration -Name 'AddClusteredIndex'

        Invoke-RTRivet -Push 'AddClusteredIndex'

        ##Assert Table and Column
        (Test-Table 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'IndexMe' -TableName 'AddIndex') | Should -BeTrue

        ##Assert Index
        Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Clustered
    }

    It 'should create unique index' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
        }

        #Add an Index to 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique
    }

    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
'@ | New-TestMigration -Name 'CreateUniqueIndex'

        Invoke-RTRivet -Push 'CreateUniqueIndex'

        ##Assert Table and Column
        (Test-Table 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'IndexMe' -TableName 'AddIndex') | Should -BeTrue

        ##Assert Index
        Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique
    }


    It 'should create index with options' {
        @'
    function Push-Migration()
    {

        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
        }

        #Add an Index to 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique -Option @('IGNORE_DUP_KEY = ON','ALLOW_ROW_LOCKS = OFF')

    }

    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
'@ | New-TestMigration -Name 'CreateIndexWithOptions'

        Invoke-RTRivet -Push 'CreateIndexWithOptions'

        ##Assert Table and Column
        (Test-Table 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'IndexMe' -TableName 'AddIndex') | Should -BeTrue

        ##Assert Index
        Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique -IgnoreDupKey -DenyRowLocks
    }


    It 'should create index with filter predicate' {
        @'
    function Push-Migration()
    {

        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
            Int 'EndDate' -NotNull
        }

        #Add an Index to 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Where 'EndDate IS NOT NULL'

    }

    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
'@ | New-TestMigration -Name 'CreateIndexWithFilterPredicate'

        Invoke-RTRivet -Push 'CreateIndexWithFilterPredicate'

        ##Assert Table and Column
        (Test-Table 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'IndexMe' -TableName 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'EndDate' -TableName 'AddIndex') | Should -BeTrue

        ##Assert Index
        Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Filter '([EndDate] IS NOT NULL)'
    }

    It 'should create index on custom file group' {
        @'
    function Push-Migration()
    {

        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
            Int 'EndDate' -NotNull
        }

        #Add an Index to 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -On 'ThisShouldFail'

    }

    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
'@ | New-TestMigration -Name 'CreateIndexOnCustomFileGroup'

        { Invoke-RTRivet -Push 'CreateIndexOnCustomFileGroup' -ErrorAction SilentlyContinue } |
            Should -Throw '*Invalid filegroup*'
    }


    It 'should create index on custom file stream' {
        @'
    function Push-Migration()
    {

        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
            Int 'EndDate' -NotNull
        }

        #Add an Index to 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -FileStreamOn 'ThisShouldFail'

    }

    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
'@ | New-TestMigration -Name 'CreateIndexOnCustomFileStream'

        { Invoke-RTRivet -Push 'CreateIndexOnCustomFileStream' -ErrorAction SilentlyContinue } |
            Should -Throw '*FILESTREAM_ON*'
    }

    It 'should create index with descending' {
    @'
    function Push-Migration()
    {

        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
        }

        #Add an Index to 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Descending @($true)

    }

    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }


'@ | New-TestMigration -Name 'CreateIndexWithDescending'

        Invoke-RTRivet -Push 'CreateIndexWithDescending'

        ##Assert Index
        Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Descending @($true)

    }

    It 'should create index with multiple descending' {
    @'
    function Push-Migration()
    {
        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
            Int 'Ascending' -NotNull
            Int 'IndexMe2' -NotNull
        }

        Add-Index -TableName 'AddIndex' -ColumnName "IndexMe","Ascending","IndexMe2" -Descending @($true, $false, $true)
    }

    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
'@ | New-TestMigration -Name 'CreateIndexWithMultipleDescending'

        Invoke-RTRivet -Push 'CreateIndexWithMultipleDescending'

        ##Assert Index
        Assert-Index -TableName 'AddIndex' -ColumnName "IndexMe","Ascending","IndexMe2" -Descending @($true, $false, $true)
    }

    It 'should quote index name' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'Add-Index' {
            Int 'IndexMe' -NotNull
        }

        Add-Index -TableName 'Add-Index' -ColumnName 'IndexMe'
    }

    function Pop-Migration()
    {
        Remove-Table 'Add-Index'
    }
'@ | New-TestMigration -Name 'AddIndex'

        Invoke-RTRivet -Push 'AddIndex'

        Assert-Index -TableName 'Add-Index' -ColumnName 'IndexMe'
    }

    It 'should add index with optional name' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'Add-Index' {
            Int 'IndexMe' -NotNull
        }

        Add-Index -TableName 'Add-Index' -ColumnName 'IndexMe' -Name 'Example'
    }

    function Pop-Migration()
    {
        Remove-Table 'Add-Index'
    }
'@ | New-TestMigration -Name 'AddIndexWithOptionalName'

        Invoke-RTRivet -Push 'AddIndexWithOptionalName'
        Assert-Index -Name 'Example' -ColumnName 'IndexMe'
    }

    It 'should add index with include column' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'AddIndex' {
            Int 'Index Me' -NotNull
            Int 'Include Me' -NotNull
        }

        #Add an Index to 'Index Me' and include the column 'Include Me'
        Add-Index -TableName 'AddIndex' -ColumnName 'Index Me' -Include 'Include Me'
    }

    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
'@ | New-TestMigration -Name 'AddIndex'

        Invoke-RTRivet -Push 'AddIndex'

        Assert-Index -TableName 'AddIndex' -ColumnName 'Index Me' -Include 'Include Me'
    }

    It 'should add index with multiple include columns' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'AddIndex' {
            Int 'Index Me' -NotNull
            Int 'Include Me' -NotNull
            Int 'Include Me 2' -NotNull
        }

        #Add an Index to 'Index Me' and include the column 'Include Me'
        Add-Index -TableName 'AddIndex' -ColumnName 'Index Me' -Include "Include Me","Include Me 2"
    }

    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
'@ | New-TestMigration -Name 'AddIndex'

        Invoke-RTRivet -Push 'AddIndex'

        Assert-Index -TableName 'AddIndex' -ColumnName 'Index Me' -Include "Include Me","Include Me 2"
    }

    It 'should set timeout' {
        $op = Add-Index -TableName 'fubar' -SchemaName 'snafu' -ColumnName 'fubar','snafu' -Timeout 400
        $op.CommandTimeout | Should -Be 400
    }

    It 'should set timeout to zero' {
        $op = Add-Index -TableName 'fubar' -ColumnName 'snafu' -Timeout 0
        $op.CommandTimeout | Should -Be 0
    }
}
