
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddForeignKey' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddForeignKeyFromSingleColumnToSingleColumn
{
    Invoke-Rivet -Push 'AddForeignKeyFromSingleColumnToSingleColumn'
    Assert-ForeignKey -TableName 'Source' -ColumnName 'source_id'
}

function Test-ShouldAddForeignKeyFromMultipleColumnToMultipleColumn
{
    Invoke-Rivet -Push 'AddForeignKeyFromMultipleColumnToMultipleColumn'
    Assert-ForeignKey -TableName 'Source' -ColumnName 's_id_1','s_id_2'
}

function Test-ShouldAddForeignKeyWithOnDelete
{
    Invoke-Rivet -Push 'AddForeignKeyWithOnDelete'
    Assert-ForeignKey -TableName 'Source' -ColumnName 'source_id' -OnDelete 'CASCADE'

}

function Test-ShouldAddForeignKeyWithOnUpdate
{
    Invoke-Rivet -Push 'AddForeignKeyWithOnUpdate'
    Assert-ForeignKey -TableName 'Source' -ColumnName 'source_id' -OnDelete 'CASCADE' -OnUpdate 'CASCADE'
}

function Test-ShouldAddForeignKeyNotForReplication
{
    Invoke-Rivet -Push 'AddForeignKeyNotForReplication'
    Assert-ForeignKey -TableName 'Source' -ColumnName 'source_id' -OnDelete 'CASCADE' -OnUpdate 'CASCADE' -NotForReplication

}