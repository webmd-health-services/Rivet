function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest' 
    Start-RivetTest

    # yes, on PowerShell 2 these tests need a breather.  Not sure why.
    if( $PSVersionTable.PsVersion -eq '2.0' )
    {
        Start-Sleep -Milliseconds 200
    }
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
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
}
'@ | New-Migration -Name 'AddUniqueKeyToOneColumn'
    Invoke-Rivet -Push 'AddUniqueKeyToOneColumn'
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
}
'@ | New-Migration -Name 'AddUniqueKeyToMultipleColumns'
    Invoke-Rivet -Push 'AddUniqueKeyToMultipleColumns'
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
}
'@ | New-Migration -Name 'AddUniqueKeyWithClustered'
    Invoke-Rivet -Push 'AddUniqueKeyWithClustered'
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
}
'@ | New-Migration -Name 'AddUniqueKeyWithFillFactor'
    Invoke-Rivet -Push 'AddUniqueKeyWithFillFactor'
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
}
'@ | New-Migration -Name 'AddUniqueKeyWithOptions'
    Invoke-Rivet -Push 'AddUniqueKeyWithOptions'
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
}
'@ | New-Migration -Name 'AddUniqueKeyWithCustomFileGroup'
    $Error.Clear()
    Invoke-Rivet -Push 'AddUniqueKeyWithCustomFileGroup' -ErrorAction SilentlyContinue
    Assert-True (0 -lt $Error.Count)
    Assert-Like $Error[1].Exception.Message '*Invalid filegroup*'
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
}
'@ | New-Migration -Name 'AddUniqueKeyToOneColumn'
    Invoke-Rivet -Push 'AddUniqueKeyToOneColumn'
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
}
'@ | New-Migration -Name 'AddUniqueKeyWithCustomName'
    Invoke-Rivet -Push 'AddUniqueKeyWithCustomName'
    
    $UQC = Invoke-RivetTestQuery -Query "select * from sys.indexes where is_unique_constraint='True'"

    Assert-Equal 'Custom' $UQC.name

}