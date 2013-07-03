
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'PstepTest') -ArgumentList 'RedoMigration' 
    Start-PstepTest

    Invoke-Pstep -Push
    
    Assert-Equal 2 (Measure-Migration)
}

function TearDown
{
    Stop-PstepTest
    Remove-Module PstepTest
}

function Test-ShouldPopThenPushTopMigration
{
    $redoMigrationTable = Get-Table -Name 'RedoMigration'
    $secondTable = Get-Table -Name 'SecondTable'

    $migrationInfo = Get-MigrationInfo -Name 'SecondTable'
    
    Invoke-Pstep -Redo
    
    # Make sure only one migration was popped/pushed.
    $redoMigrationTableRedo = Get-Table -Name 'RedoMigration'
    Assert-Equal $redoMigrationTable.create_date $redoMigrationTableRedo.create_date

    $secondTableRedo = Get-Table -Name 'SecondTable'
    Assert-NotNull $secondTableRedo
    Assert-True ($redoMigrationTable.create_date -lt $secondTableRedo.create_date)

    $redoMigrationInfo = Get-MigrationInfo -Name 'AddColumn'
    Assert-NotNull $redoMigrationInfo
    Assert-True ($migrationInfo.AtUtc -lt $redoMigrationInfo.AtUtc)
}