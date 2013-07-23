
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'MS_Description' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldUpdateTableAndColumnDescription
{
    Invoke-Rivet -Push 'AddDescription'
    Invoke-Rivet -Push 'UpdateDescription'

    Assert-Table -Name 'MS_Description' -Description 'updated description' 
    Assert-Column -Name 'add_description' 'varchar' -Description 'updated description' -TableName MS_Description
}
