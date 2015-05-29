
function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRemoveTableAndColumnDescription
{
    @'
function Push-Migration()
{
    Add-Table 'MS_Description' -Column {
        varchar add_description -Max 
    }

    Add-Description -Description 'new description' -TableName 'MS_Description'
    Add-Description -Description 'new description' -TableName 'MS_Description' -ColumnName 'add_description'
}

function Pop-Migration()
{
    Remove-Table 'MS_Description'
}
'@ | New-Migration -Name 'AddDescription'

    Invoke-Rivet -Push 'AddDescription'

    Start-Sleep -Milliseconds 750

    Assert-Table -Name 'MS_Description' -Description 'new description'
    Assert-Column -Name 'add_description' 'varchar' -Description 'new description' -TableName MS_Description

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

    Start-Sleep -Milliseconds 750

    Assert-Table -Name 'MS_Description' -Description 'updated description'
    Assert-Column -Name 'add_description' 'varchar' -Description 'updated description' -TableName MS_Description

    @'
function Push-Migration()
{
    Remove-Description -TableName MS_Description 
    Remove-Description -TableName MS_Description -ColumnName 'add_description'
}

function Pop-Migration()
{
    Add-Description -Description 'updated description' -TableName MS_Description
    Add-Description -Description 'updated description' -TableName MS_Description -ColumnName 'add_description'
}
'@ | New-Migration -Name 'RemoveDescription'

    Invoke-Rivet -Push 'RemoveDescription'
    Assert-Table -Name 'MS_Description' -Description $null 
    Assert-Column -Name 'add_description' 'varchar' -Description $null -TableName MS_Description
}
