
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
    Invoke-Pstep -Push 'UpdateDescription'
    Invoke-Pstep -Push 'RemoveDescription'

    Assert-Table -Name 'MS_Description' -Description $null 
    Assert-Column -Name 'add_description' 'varchar' -Description $null -TableName MS_Description
}
