& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Setup
{
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldAddUniqueKeyToOneColumn
{
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
'@ | New-Migration -Name 'AddUniqueKeyToOneColumn'
    Invoke-RTRivet -Push 'AddUniqueKeyToOneColumn'
    Assert-UniqueKey -TableName 'Add Unique Key' -ColumnName 'Unique Key Me'
}

function Test-ShouldAddUniqueKeyToMultipleColumns
{
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
'@ | New-Migration -Name 'AddUniqueKeyToMultipleColumns'
    Invoke-RTRivet -Push 'AddUniqueKeyToMultipleColumns'
    Assert-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe','UniqueKeyMe2'
}

function Test-ShouldAddUniqueKeyWithClustered
{
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
'@ | New-Migration -Name 'AddUniqueKeyWithClustered'
    Invoke-RTRivet -Push 'AddUniqueKeyWithClustered'
    Assert-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe','UniqueKeyMe2' -Clustered
}

function Test-ShouldAddUniqueKeyWithFillFactor
{
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
'@ | New-Migration -Name 'AddUniqueKeyWithFillFactor'
    Invoke-RTRivet -Push 'AddUniqueKeyWithFillFactor'
    Assert-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe','UniqueKeyMe2' -FillFactor 80 -IgnoreDupKey -DenyRowLocks
}

function Test-ShouldAddUniqueKeyWithOptions
{
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
'@ | New-Migration -Name 'AddUniqueKeyWithOptions'
    Invoke-RTRivet -Push 'AddUniqueKeyWithOptions'
    Assert-UniqueKey -TableName 'AddUniqueKey' -ColumnName 'UniqueKeyMe','UniqueKeyMe2' -IgnoreDupKey -DenyRowLocks
}

function Test-ShouldAddUniqueKeyWithCustomFileGroup
{
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
'@ | New-Migration -Name 'AddUniqueKeyWithCustomFileGroup'
    Invoke-RTRivet -Push 'AddUniqueKeyWithCustomFileGroup' -ErrorAction SilentlyContinue
    Assert-Error 1 'Invalid filegroup'
}

function Test-ShouldQuoteUniqueKeyName
{
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
'@ | New-Migration -Name 'AddUniqueKeyToOneColumn'
    Invoke-RTRivet -Push 'AddUniqueKeyToOneColumn'
    Assert-UniqueKey -TableName 'Add-UniqueKey' -ColumnName 'UniqueKeyMe'
}

function Test-ShouldAddUniqueKeyWithCustomName
{
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
'@ | New-Migration -Name 'AddUniqueKeyWithCustomName'
    Invoke-RTRivet -Push 'AddUniqueKeyWithCustomName'
    
    $UQC = Invoke-RivetTestQuery -Query "select * from sys.indexes where is_unique_constraint='True'"

    Assert-Equal 'Custom' $UQC.name

}
