
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest' 
    Start-RivetTest

    Invoke-Rivet -Push
    
    $expectedCount = Measure-MigrationScript
    Assert-Equal $expectedCount (Measure-Migration)
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldPopAllMigrations
{
    $migrationCount = Measure-Migration
    Assert-True ($migrationCount -gt 1)
    
    Invoke-Rivet -Pop $migrationCount
    Assert-LastProcessSucceeded
    
    Assert-Equal 0 (Measure-Migration)
    
    Get-MigrationScript | ForEach-Object {
        
        $id,$name = $_.BaseName -split '_'
        
        Assert-False (Test-Table -Name $name)
    }
    
    Assert-False (Test-Table -Name 'InvokeQuery')
    Assert-False (Test-Table -Name 'SecondTable')
    Assert-False (Test-DatabaseObject -StoredProcedure 'RivetTestSproc')
    Assert-False (Test-DatabaseObject -ScalarFunction 'RivetTestFunction') 'user-defined function not dropped'
    Assert-False (Test-DatabaseObject -View 'Migrators') 'view not dropped'
    Assert-False (Test-DatabaseObject -ScalarFunction 'MiscellaneousObject') 'the miscellaneous function not dropped'
}

function Test-ShouldWriteToActivityTableOnPop
{
    $migrationCount = Measure-Migration
    Assert-True ($migrationCount -gt 1)

    Invoke-Rivet -Pop 1
    Assert-LastProcessSucceeded

    Assert-Equal ($migrationCount-1) (Measure-Migration)

    $rows = Get-ActivityInfo

    Assert-Equal 'Pop' $rows[4].Operation
    Assert-Equal 'CreateObjectInCustomDirectory' $rows[4].Name
    Assert-Equal 5 $rows[4].ID
}

function Test-ShouldPopSpecificNumberOfDatabaseMigrations
{
    $rivetCount = Measure-Migration
    Assert-True ($rivetCount -gt 1)

    Invoke-Rivet -Pop 2
        
    Assert-Equal ($rivetCount - 2) (Measure-Migration)
}

function Test-ShouldPopOneMigrationByDefault
{
    $totalMigrations = Measure-Migration
    
    Invoke-Rivet -Pop
    
    Assert-Equal ($totalMigrations - 1) (Measure-Migration)
    
    $firstMigration = Get-MigrationScript | Select-Object -First 1
                        
    $id,$name = $firstMigration.BaseName -split '_'
    Assert-True (Test-Table -Name $name)
}

function Test-ShouldNotRePopMigrations
{
    $originalMigrationCount = Measure-Migration
    Invoke-Rivet -Pop
    Assert-LastProcessSucceeded
    Assert-Equal 0 ($error.Count)
    Assert-Equal ($originalMigrationCount - 1) (Measure-Migration)
    
    Invoke-Rivet -Pop 2
    Assert-LastProcessSucceeded
    Assert-Equal 0 ($error.Count)
    Assert-Equal ($originalMigrationCount - 2) (Measure-Migration)
    
    Invoke-Rivet -Pop 2
    Assert-LastProcessSucceeded
    Assert-Equal 0 ($error.Count)
    Assert-Equal ($originalMigrationCount - 2) (Measure-Migration)
}

function Test-ShouldSupportPoppingMoreThanAvailableMigrations
{
    $migrationCount = Measure-Migration
    Invoke-Rivet -Pop ($migrationCount * 2) 
    Assert-LastProcessSucceeded
    Assert-Equal 0 ($error.Count)
    Assert-Equal 0 (Measure-Migration)
}


function Test-ShouldStopPoppingMigrationsIfOneGivesAnError
{
    $script = Get-MigrationScript | Select-Object -First 1
    $migrationDir = Split-Path -Parent -Path $script.FullName
    Copy-Item -Path (Join-Path $migrationDir Extras\*.ps1) -Destination $migrationDir
    Remove-Item -Path (Join-Path $migrationDir *_TableWithoutColumns.ps1)
    
    Invoke-Rivet -Push
    Assert-LastProcessSucceeded
    Assert-True ($error.Count -eq 0)
    
    ('SecondTable','PushSucceedsPopFails','FourthTable') | ForEach-Object {
        Assert-True (Test-Table -Name $_)
    }

    Invoke-Rivet -Pop (Measure-Migration) -ErrorAction SilentlyContinue -ErrorVariable rivetError

    Assert-NotNull $rivetError
    Assert-Like $rivetError[0] '*cannot drop the table*'
    
    Assert-True (Test-Table -Name 'SecondTable')
    Assert-True (Test-Table -Name 'PushSucceedsPopFails')
    Assert-False (Test-Table -Name 'FourthTable')
        
}
