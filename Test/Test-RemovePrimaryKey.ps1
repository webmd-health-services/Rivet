
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

function Test-ShouldRemovePrimaryKey
{
    @'
function Push-Migration()
{
    Add-Table -Name 'PrimaryKey' {
        Int 'id' -NotNull
    }

    Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
}

function Pop-Migration()
{
    Remove-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
}
'@ | New-Migration -Name 'SetandRemovePrimaryKey'
    Invoke-Rivet -Push 'SetandRemovePrimaryKey'
    Assert-True (Test-Table 'PrimaryKey')
    Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'

    Invoke-Rivet -Pop
    Assert-NoPrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
}

function Test-ShouldQuotePrimaryKeyName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Remove-PrimaryKey' {
        Int 'id' -NotNull
    }

    Add-PrimaryKey -TableName 'Remove-PrimaryKey' -ColumnName 'id'
}

function Pop-Migration()
{
    Remove-PrimaryKey -TableName 'Remove-PrimaryKey' -ColumnName 'id'
}
'@ | New-Migration -Name 'SetandRemovePrimaryKey'
    Invoke-Rivet -Push 'SetandRemovePrimaryKey'
    Invoke-Rivet -Pop
    Assert-NoPrimaryKey -TableName 'Remove-PrimaryKey' -ColumnName 'id'
}

