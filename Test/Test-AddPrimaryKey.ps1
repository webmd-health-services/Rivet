
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
}

function Test-ShouldAddNonClusteredPrimaryKey
{
}

function Test-ShouldSetIndexOptions
{
}

function Test-ShouldRemovePrimaryKey
{
}

function Test-ShouldAddPrimaryKeyToTableInCustomSchema
{
}

