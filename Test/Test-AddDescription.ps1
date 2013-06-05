
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

function Test-ShouldAddTableAndColumnDescription
{
    Invoke-Pstep -Push 'AddDescription'

    Assert-Table -Name 'MS_Description' -Description 'new description' 
    Assert-Column -Name 'add_description' 'varchar' -Description 'new description' -TableName MS_Description
}
