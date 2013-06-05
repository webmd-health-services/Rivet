
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
    INvoke-Pstep -Push 'UpdateDescription'

    Assert-Table -Name 'MS_Description' -Description 'updated description' 
    Assert-Column -Name 'add_description' 'varchar' -Description 'updated description' -TableName MS_Description
}
