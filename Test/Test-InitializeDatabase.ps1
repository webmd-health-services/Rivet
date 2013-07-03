
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'PstepTest') -ArgumentList 'PstepTest' 
    Start-PstepTest

    Assert-True (Test-Database)
}

function TearDown
{
    Stop-PstepTest
    Remove-Module PstepTest
}

function Test-ShouldCreatePstepObjectsInDatabase
{
    Invoke-Pstep -Push
    
    Assert-True (Test-Database)
    Assert-True (Test-Schema -Name 'pstep')                
    Assert-True (Test-Table -Name 'Migrations' -SchemaName 'pstep')
}
