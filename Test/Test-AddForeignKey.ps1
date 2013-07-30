
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
    Assert-ForeignKey -TableName 'Source' -References 'Reference'
}

function Test-ShouldAddForeignKeyFromMultipleColumnToMultipleColumn
{
    Invoke-Rivet -Push 'AddForeignKeyFromMultipleColumnToMultipleColumn'
    Assert-ForeignKey -TableName 'Source' -References 'Reference'
}

function Test-ShouldAddForeignKeyWithCustomSchema
{
    Invoke-Rivet -Push 'AddForeignKeyWithCustomSchema'
    Assert-ForeignKey -TableName 'Source' -SchemaName 'rivet' -References 'Reference' -ReferencesSchema 'rivet'
}

function Test-ShouldAddForeignKeyWithOnDelete
{
    Invoke-Rivet -Push 'AddForeignKeyWithOnDelete'
    Assert-ForeignKey -TableName 'Source' -References 'Reference' -OnDelete 'CASCADE'

}

function Test-ShouldAddForeignKeyWithOnUpdate
{
    Invoke-Rivet -Push 'AddForeignKeyWithOnUpdate'
    Assert-ForeignKey -TableName 'Source' -References 'Reference' -OnDelete 'CASCADE' -OnUpdate 'CASCADE'
}

function Test-ShouldAddForeignKeyNotForReplication
{
    Invoke-Rivet -Push 'AddForeignKeyNotForReplication'
    Assert-ForeignKey -TableName 'Source' -References 'Reference' -OnDelete 'CASCADE' -OnUpdate 'CASCADE' -NotForReplication

}