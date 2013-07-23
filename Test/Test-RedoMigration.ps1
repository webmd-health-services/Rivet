
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RedoMigration' 
    Start-RivetTest

    Invoke-Rivet -Push
    
    Assert-Equal 2 (Measure-Migration)
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldPopThenPushTopMigration
{
    $redoMigrationTable = Get-Table -Name 'RedoMigration'
    $secondTable = Get-Table -Name 'SecondTable'

    $migrationInfo = Get-MigrationInfo -Name 'SecondTable'
    
    Invoke-Rivet -Redo
    
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