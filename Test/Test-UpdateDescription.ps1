
function Setup
{
    & (Join-Path -Path $TestDir -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'MS_Description' 
    Start-RivetTest
}

function Stop-Test
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
