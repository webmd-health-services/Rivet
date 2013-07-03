
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'PstepTest') -ArgumentList 'PstepTest' 
    Start-PstepTest

    Invoke-Pstep -Push
    
    $expectedCount = Measure-MigrationScript
    Assert-Equal $expectedCount (Measure-Migration)
}

function TearDown
{
    Stop-PstepTest
    Remove-Module PstepTest
}

function Test-ShouldPopAllMigrations
{
    $migrationCount = Measure-Migration
    Assert-True ($migrationCount -gt 1)
    
    Invoke-Pstep -Pop $migrationCount
    Assert-LastProcessSucceeded
    
    Assert-Equal 0 (Measure-Migration)
    
    Get-MigrationScript | ForEach-Object {
        
        $id,$name = $_.BaseName -split '_'
        
        Assert-False (Test-Table -Name $name)
    }
    
    Assert-False (Test-Table -Name 'InvokeQuery')
    Assert-False (Test-Table -Name 'SecondTable')
    Assert-False (Test-DatabaseObject -StoredProcedure 'PstepTestSproc')
    Assert-False (Test-DatabaseObject -ScalarFunction 'PstepTestFunction') 'user-defined function not dropped'
    Assert-False (Test-DatabaseObject -View 'Migrators') 'view not dropped'
    Assert-False (Test-DatabaseObject -ScalarFunction 'MiscellaneousObject') 'the miscellaneous function not dropped'
}

function Test-ShouldPopSpecificNumberOfDatabaseMigrations
{
    $pstepCount = Measure-Migration
    Assert-True ($pstepCount -gt 1)

    Invoke-Pstep -Pop 2
        
    Assert-Equal ($pstepCount - 2) (Measure-Migration)
}

function Test-ShouldPopOneMigrationByDefault
{
    $totalMigrations = Measure-Migration
    
    Invoke-Pstep -Pop
    
    Assert-Equal ($totalMigrations - 1) (Measure-Migration)
    
    $firstMigration = Get-MigrationScript | Select-Object -First 1
                        
    $id,$name = $firstMigration.BaseName -split '_'
    Assert-True (Test-Table -Name $name)
}

function Test-ShouldNotRePopMigrations
{
    $originalMigrationCount = Measure-Migration
    Invoke-Pstep -Pop
    Assert-LastProcessSucceeded
    Assert-Equal 0 ($error.Count)
    Assert-Equal ($originalMigrationCount - 1) (Measure-Migration)
    
    Invoke-Pstep -Pop 2
    Assert-LastProcessSucceeded
    Assert-Equal 0 ($error.Count)
    Assert-Equal ($originalMigrationCount - 2) (Measure-Migration)
    
    Invoke-Pstep -Pop 2
    Assert-LastProcessSucceeded
    Assert-Equal 0 ($error.Count)
    Assert-Equal ($originalMigrationCount - 2) (Measure-Migration)
}

function Test-ShouldSupportPoppingMoreThanAvailableMigrations
{
    $migrationCount = Measure-Migration
    Invoke-Pstep -Pop ($migrationCount * 2) 
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
    
    Invoke-Pstep -Push
    Assert-LastProcessSucceeded
    Assert-True ($error.Count -eq 0)
    
    ('SecondTable','PushSucceedsPopFails','FourthTable') | ForEach-Object {
        Assert-True (Test-Table -Name $_)
    }

    Invoke-Pstep -Pop (Measure-Migration) -ErrorAction SilentlyContinue -ErrorVariable pstepError

    Assert-NotNull $pstepError
    Assert-Like $pstepError[0] '*cannot drop the table*'
    
    Assert-True (Test-Table -Name 'SecondTable')
    Assert-True (Test-Table -Name 'PushSucceedsPopFails')
    Assert-False (Test-Table -Name 'FourthTable')
        
}
