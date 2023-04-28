
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Add-UniqueKey' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }


    It 'should add unique key to one column' {
        # Yes.  Spaces in names so we check that the names get quoted.
        @'
function Push-Migration()
{
    Add-Table -Name 'Add Unique Key' {
        Int 'Unique Key Me' -NotNull
    }

    Add-UniqueKey -TableName 'Add Unique Key' -ColumnName 'Unique Key Me'
}

function Pop-Migration()
{
    Remove-Table 'Add Unique Key'
}
'@ | New-TestMigration -Name 'AddUniqueKeyToOneColumn'
        Invoke-RTRivet -Push 'AddUniqueKeyToOneColumn'
        Assert-UniqueKey -TableName 'Add Unique Key' -ColumnName 'Unique Key Me'
    }

    It 'should add unique key to multiple columns' {
        @'
function Push-Migration()
{
    Add-Table -Name 'AddUniqueKey' {
        Int 'UniqueKeyMe' -NotNull
        Int 'UniqueKeyMe2' -NotNull
        Int 'DoNotUniqueKeyMe' -NotNull
    }

    Add-UniqueKey 'AddUniqueKey' 'UniqueKeyMe','UniqueKeyMe2'
}

function Pop-Migration()
{
    Remove-Table AddUniqueKey
}
'@ | New-TestMigration -Name 'AddUniqueKeyToMultipleColumns'
        Invoke-RTRivet -Push 'AddUniqueKeyToMultipleColumns'
        Assert-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe','UniqueKeyMe2'
    }

    It 'should add unique key with clustered' {
    @'
function Push-Migration()
{
    Add-Table -Name 'AddUniqueKey' {
        Int 'UniqueKeyMe' -NotNull
        Int 'UniqueKeyMe2' -NotNull
        Int 'DoNotUniqueKeyMe' -NotNull
    }

    Add-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe','UniqueKeyMe2' -Clustered
}

function Pop-Migration()
{
    Remove-Table AddUniqueKey
}
'@ | New-TestMigration -Name 'AddUniqueKeyWithClustered'
        Invoke-RTRivet -Push 'AddUniqueKeyWithClustered'
        Assert-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe','UniqueKeyMe2' -Clustered
    }

    It 'should add unique key with fill factor' {
        @'
function Push-Migration()
{
    Add-Table -Name 'AddUniqueKey' {
        Int 'UniqueKeyMe' -NotNull
        Int 'UniqueKeyMe2' -NotNull
        Int 'DoNotUniqueKeyMe' -NotNull
    }

    Add-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe','UniqueKeyMe2' -Option @('IGNORE_DUP_KEY = ON','ALLOW_ROW_LOCKS = OFF') -FillFactor 80
}

function Pop-Migration()
{
    Remove-Table AddUniqueKey
}
'@ | New-TestMigration -Name 'AddUniqueKeyWithFillFactor'
        Invoke-RTRivet -Push 'AddUniqueKeyWithFillFactor'
        Assert-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe','UniqueKeyMe2' -FillFactor 80 -IgnoreDupKey -DenyRowLocks
    }

    It 'should add unique key with options' {
        @'
function Push-Migration()
{
    Add-Table -Name 'AddUniqueKey' {
        Int 'UniqueKeyMe' -NotNull
        Int 'UniqueKeyMe2' -NotNull
        Int 'DoNotUniqueKeyMe' -NotNull
    }

    Add-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe','UniqueKeyMe2' -Option @('IGNORE_DUP_KEY = ON','ALLOW_ROW_LOCKS = OFF')
}

function Pop-Migration()
{
    Remove-Table AddUniqueKey
}
'@ | New-TestMigration -Name 'AddUniqueKeyWithOptions'
        Invoke-RTRivet -Push 'AddUniqueKeyWithOptions'
        Assert-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe','UniqueKeyMe2' -IgnoreDupKey -DenyRowLocks
    }

    It 'should add unique key with custom file group' {
        @'
function Push-Migration()
{

    Add-Table -Name 'AddUniqueKey' {
        Int 'UniqueKeyMe' -NotNull
    }

    Add-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe' -On 'ThisShouldFail'
}
function Pop-Migration()
{
    Remove-Table AddUniqueKey
}
'@ | New-TestMigration -Name 'AddUniqueKeyWithCustomFileGroup'
        { Invoke-RTRivet -Push 'AddUniqueKeyWithCustomFileGroup' -ErrorAction SilentlyContinue } |
            Should -Throw '*Invalid filegroup*'
        $Global:Error.Count | Should -BeGreaterThan 0
    }

    It 'should quote unique key name' {
        @'
function Push-Migration()
{
    Add-Table -Name 'Add-UniqueKey' {
        Int 'UniqueKeyMe' -NotNull
    }

    Add-UniqueKey -TableName 'Add-UniqueKey' -ColumnName 'UniqueKeyMe'
}

function Pop-Migration()
{
    Remove-Table 'Add-UniqueKey'
}
'@ | New-TestMigration -Name 'AddUniqueKeyToOneColumn'
        Invoke-RTRivet -Push 'AddUniqueKeyToOneColumn'
        Assert-UniqueKey -TableName 'Add-UniqueKey' -ColumnName 'UniqueKeyMe'
    }

    It 'should add unique key with custom name' {
        @'
function Push-Migration()
{
    Add-Table -Name 'Add-UniqueKey' {
        Int 'UniqueKeyMe' -NotNull
    }

    Add-UniqueKey -TableName 'Add-UniqueKey' -ColumnName 'UniqueKeyMe' -Name 'Custom'
}

function Pop-Migration()
{
    Remove-Table 'Add-UniqueKey'
}
'@ | New-TestMigration -Name 'AddUniqueKeyWithCustomName'
        Invoke-RTRivet -Push 'AddUniqueKeyWithCustomName'

        $UQC = Invoke-RivetTestQuery -Query "select * from sys.indexes where is_unique_constraint='True'"

        $UQC.name | Should -Be 'Custom'

    }
}
