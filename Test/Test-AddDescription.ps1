
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

function Test-ShouldAddTableAndColumnDescription
{
    @'
function Push-Migration()
{
    Invoke-Query @"
    create table [MS_Description] (
        add_description varchar(max)
    )
"@

    Add-Description -Description 'new description' -TableName 'MS_Description'
    Add-Description -Description 'new description' -TableName 'MS_Description' -ColumnName 'add_description'
}

function Pop-Migration()
{
    Invoke-Query 'drop table [MS_Description]'
}
'@ | New-Migration -Name 'AddDescription'
    Invoke-Rivet -Push 'AddDescription'

    Assert-Table -Name 'MS_Description' -Description 'new description' 
    Assert-Column -Name 'add_description' 'varchar' -Description 'new description' -TableName 'MS_Description'
}
