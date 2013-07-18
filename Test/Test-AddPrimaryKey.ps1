
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddPrimaryKey' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddPrimaryKey
{
    Invoke-Rivet -Push 'AddTableWithPrimaryKey'
    Assert-True (Test-Table 'PrimaryKey')
    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
}

function Test-ShouldAddPrimaryKeyWithMultipleColumns
{
    Invoke-Rivet -Push 'AddTableWithPrimaryKeyWithMultipleColumns'
    Assert-True (Test-Table 'PrimaryKey')

    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id','uuid','date'

}

function Test-ShouldAddNonClusteredPrimaryKey
{
    Invoke-Rivet -Push 'AddNonClusteredPrimaryKey'
    Assert-True (Test-Table 'PrimaryKey')

    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -NonClustered
}

function Test-ShouldSetIndexOptions
{
    Invoke-Rivet -Push 'SetIndexOptions'
    Assert-True (Test-Table 'PrimaryKey')

    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -WithOptions
}

function Test-ShouldRemovePrimaryKey
{
    # Add Primary Key, Assert

    Invoke-Rivet -Push 'AddTableWithPrimaryKey'
    Assert-True (Test-Table 'PrimaryKey')
    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'

    # Remove Primary Key, Assert

    Invoke-Rivet -Pop 


}

function Test-ShouldAddPrimaryKeyToTableInCustomSchema
{
}

