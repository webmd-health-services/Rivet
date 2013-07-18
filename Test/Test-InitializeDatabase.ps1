
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest' 
    Start-RivetTest

    Assert-True (Test-Database)
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateRivetObjectsInDatabase
{
    Invoke-Rivet -Push
    
    Assert-True (Test-Database)
    Assert-True (Test-Schema -Name 'pstep')                
    Assert-True (Test-Table -Name 'Migrations' -SchemaName 'pstep')
}
