
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'PstepTest') -ArgumentList 'MS_Description' 
    Start-PstepTest
}

function TearDown
{
    Stop-PstepTest
    Remove-Module PstepTest
}

function Test-ShouldUpdateTableAndColumnDescription
{
    Invoke-Pstep -Push 'AddDescription'
    Assert-Table -Name 'MS_Description' -Description 'new description'
    Assert-Column -Name 'add_description' 'varchar' -Description 'new description' -TableName MS_Description

    Invoke-Pstep -Push 'UpdateDescription'
    Assert-Table -Name 'MS_Description' -Description 'updated description'
    Assert-Column -Name 'add_description' 'varchar' -Description 'updated description' -TableName MS_Description

    Invoke-Pstep -Push 'RemoveDescription'
    Assert-Table -Name 'MS_Description' -Description $null 
    Assert-Column -Name 'add_description' 'varchar' -Description $null -TableName MS_Description
}
