
function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddPrimaryKey
{
    @'
function Push-Migration()
{
    Add-Table -Name 'PrimaryKey' {
        Int 'id' -NotNull
    }

    Add-PrimaryKey 'PrimaryKey' 'id'
}

function Pop-Migration()
{
    Remove-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
    Remove-Table -Name 'PrimaryKey'
}

'@ | New-Migration -Name 'AddTableWithPrimaryKey'
    Invoke-Rivet -Push 'AddTableWithPrimaryKey'
    Assert-True (Test-Table 'PrimaryKey')
    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
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
}
'@ | New-Migration -Name 'SetIndexOptions'
    Invoke-Rivet -Push 'SetIndexOptions'
    Assert-True (Test-Table 'PrimaryKey')
    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -WithOptions 
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
}

'@ | New-Migration -Name 'AddTableWithPrimaryKey'
    Invoke-Rivet -Push 'AddTableWithPrimaryKey'
    Assert-PrimaryKey -TableName 'Add-PrimaryKey' -ColumnName 'id'
}
