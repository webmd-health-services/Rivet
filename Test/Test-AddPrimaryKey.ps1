
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'RivetTest' 

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldAddPrimaryKey
{
    # Yes.  Spaces in the name so we check the name gets quoted.
    @'
function Push-Migration()
{
    Add-Table -Name 'Primary Key' {
        Int 'PK ID' -NotNull
    }

    Add-PrimaryKey 'Primary Key' 'PK ID'
}

function Pop-Migration()
{
    Remove-PrimaryKey -TableName 'Primary Key'
    Remove-Table -Name 'Primary Key'
}

'@ | New-Migration -Name 'AddTableWithPrimaryKey'
    Invoke-Rivet -Push 'AddTableWithPrimaryKey'
    Assert-True (Test-Table 'Primary Key')
    Assert-PrimaryKey -TableName 'Primary Key' -ColumnName 'PK ID'
}

function Test-ShouldAddPrimaryKeyWithMultipleColumns
{
    @'
function Push-Migration()
{

    Add-Table -Name 'PrimaryKey' {
        Int 'id' -NotNull
        UniqueIdentifier 'uuid' -NotNull
        DateTimeOffset 'date' -NotNull
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id','uuid','date'

}

function Pop-Migration()
{
    Remove-Table 'PrimaryKey'
}
'@ | New-Migration -Name 'AddTableWithPrimaryKeyWithMultipleColumns'
    Invoke-Rivet -Push 'AddTableWithPrimaryKeyWithMultipleColumns'
    Assert-True (Test-Table 'PrimaryKey')
    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id','uuid','date'
}

function Test-ShouldAddNonClusteredPrimaryKey
{
    @'
function Push-Migration()
{

    Add-Table -Name 'PrimaryKey' {
        Int 'id' -NotNull
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -NonClustered

}

function Pop-Migration()
{
    Remove-Table 'PrimaryKey'
}
'@ | New-Migration -Name 'AddNonClusteredPrimaryKey'
    Invoke-Rivet -Push 'AddNonClusteredPrimaryKey'
    Assert-True (Test-Table 'PrimaryKey')
    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -NonClustered
}

function Test-ShouldSetIndexOptions
{
    @'
function Push-Migration()
{

    Add-Table -Name 'PrimaryKey' {
        Int 'id' -NotNull
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -Option 'IGNORE_DUP_KEY = ON','FILLFACTOR = 75'

}

function Pop-Migration()
{
    Remove-Table 'PrimaryKey'
}
'@ | New-Migration -Name 'SetIndexOptions'
    Invoke-Rivet -Push 'SetIndexOptions'
    Assert-True (Test-Table 'PrimaryKey')
    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -IgnoreDupKey -FillFActor 75 
}

function Test-ShouldAddPrimaryKeyToTableInCustomSchema
{
    @'
function Push-Migration()
{
    Add-Table -Name 'PrimaryKey' -SchemaName 'rivet' {
        Int 'id' -NotNull 
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -SchemaName 'rivet' -ColumnName 'id'

}

function Pop-Migration()
{
    Remove-Table 'PrimaryKey' -SchemaName 'rivet'
}
'@ | New-Migration -Name 'AddPrimaryKeyToTableInCustomSchema'
    Invoke-Rivet -Push 'AddPrimaryKeyToTableInCustomSchema'
    Assert-True (Test-Table 'PrimaryKey' -SchemaName 'rivet')
    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -SchemaName 'rivet'
}

function Test-ShouldQuotePrimaryKeyName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Add-PrimaryKey' {
        Int 'id' -NotNull
    }

    Add-PrimaryKey -TableName 'Add-PrimaryKey' -ColumnName 'id'
}

function Pop-Migration()
{
    Remove-Table 'Add-PrimaryKey'
}

'@ | New-Migration -Name 'AddTableWithPrimaryKey'
    Invoke-Rivet -Push 'AddTableWithPrimaryKey'
    Assert-PrimaryKey -TableName 'Add-PrimaryKey' -ColumnName 'id'
}

function Test-ShouldAddPrimaryKeyWithCustomName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Add-PrimaryKey' {
        Int 'id' -NotNull
    }

    Add-PrimaryKey -TableName 'Add-PrimaryKey' -ColumnName 'id' -Name 'Custom'
}

function Pop-Migration()
{
    Remove-Table 'Add-PrimaryKey'
}

'@ | New-Migration -Name 'AddPrimaryKeyWithCustomName'
    Invoke-Rivet -Push 'AddPrimaryKeyWithCustomName'

    Assert-PrimaryKey -Name 'Custom' -ColumnName 'id'
}