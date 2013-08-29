
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

function Test-ShouldAddTableAndColumnDescription
{
    Invoke-Rivet -Push 'AddDescription'

    Assert-Table -Name 'MS_Description' -Description 'new description' 
    Assert-Column -Name 'add_description' 'varchar' -Description 'new description' -TableName 'MS_Description'
}
