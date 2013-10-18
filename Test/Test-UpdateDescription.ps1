
function Start-Test
{
    & (Join-Path -Path $TestDir -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldUpdateTableAndColumnDescription
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

    @'
function Push-Migration()
{
    Update-Description -Description 'updated description' -TableName MS_Description
    Update-Description -Description 'updated description' -TableName MS_Description -ColumnName 'add_description'
}

function Pop-Migration()
{
    Update-Description -Description 'new description' -TableName MS_Description
    Update-Description -Description 'new description' -TableName MS_Description -ColumnName 'add_description'
}
'@ | New-Migration -Name 'UpdateDescription'
    Invoke-Rivet -Push 'UpdateDescription'

    Assert-Table -Name 'MS_Description' -Description 'updated description' 
    Assert-Column -Name 'add_description' 'varchar' -Description 'updated description' -TableName MS_Description
}
