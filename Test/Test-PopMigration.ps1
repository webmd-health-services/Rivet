
. (Join-Path $TestDir Initialize-PstepTest.ps1 -Resolve)

$connection = $null

function Setup
{
    New-Database

    $connection = Connect-Database
    
    & $pstep -Push -SqlServerName $server -Database $pstepTestDatabase -Path $pstepTestRoot
    
    $expectedCount = Get-ChildItem $pstepTestMigrationsDir *.ps1 | Measure-Object | Select-Object -ExpandProperty Count
    Assert-Equal $expectedCount (Measure-Migration)
}

function TearDown
{
    Disconnect-Database -Connection $connection
    
    Remove-Database
}

function Test-ShouldPopMultipleMigrations
{
    $migrationCount = Measure-Migration
    Assert-True ($migrationCount -gt 1)
    
    & $pstep -Pop $migrationCount -SqlServerName $server -Database $pstepTestDatabase -Path $pstepTestRoot
    Assert-LastProcessSucceeded
    
    Assert-Equal 0 (Measure-Migration)
    
    Get-ChildItem $pstepTestMigrationsDir *.ps1 | ForEach-Object {
        
        $id,$name = $_.BaseName -split '_'
        
        Assert-False (_Test-Table -Name $name)
    }
    
    Assert-False (_Test-Table -Name 'InvokeQuery')
    Assert-False (_Test-Table -Name 'SecondTable')
    Assert-False (_Test-DBObject -StoredProcedure 'PstepTestSproc')
    Assert-False (_Test-DBObject -ScalarFunction 'PstepTestFunction') 'user-defined function not dropped'
    Assert-False (_Test-DBObject -View 'Migrators') 'view not dropped'
    Assert-False (_Test-DBObject -ScalarFunction 'MiscellaneousObject') 'the miscellaneous function not dropped'
}

function Test-ShouldPopMultipleDatabaseMigrations
{
    New-Database -Name PstepTestTwo
    $twoConnection = Connect-Database -Name 'PstepTestTwo'
    
    try
    {
        & $pstep -Push -SqlServerName $server -Database $pstepTestDatabase,$pstepTestTwoDatabase -Path $dbsRoot
        
        $pstepCount = Measure-Migration
        Assert-True ($pstepCount -gt 0)
        
        $pstepTwoCount = Measure-Migration -Connection $twoConnection
        Assert-True ($pstepTwoCount -gt 0)
        
        & $pstep -Pop 1 -SqlServerName $server -Database $pstepTestDAtabase,$pstepTEstTwoDatabase -Path $dbsRoot
        
        Assert-Equal ($pstepCount - 1) (Measure-Migration)
        Assert-Equal ($pstepTwoCount - 1) (Measure-Migration -Connection $twoConnection)
        
    }
    finally
    {
        REmove-Database -Name PstepTestTwo
        Disconnect-Database -Connection $twoConnection
    }
    
}

function Test-ShouldPopOneMigrationByDefault
{
    $totalMigrations = Measure-Migration
    
    & $pstep -Pop -SqlServerName $server -Database $pstepTestDatabase -Path $pstepTestRoot
    
    Assert-Equal ($totalMigrations - 1) (Measure-Migration)
    
    $firstMigration = Get-ChildItem $pstepTestMigrationsDir *.ps1 | 
                        Sort-Object BaseName |
                        Select-Object -First 1
                        
    $id,$name = $firstMigration.BaseName -split '_'
    Assert-True (_Test-Table -Name $name)
}

function Test-ShouldNotRePopMigrations
{
    $originalMigrationCount = Measure-Migration
    & $pstep -Pop -SqlServerName $server -Database $pstepTestDatabase -Path $pstepTestRoot
    Assert-LastProcessSucceeded
    Assert-Equal 0 ($error.Count)
    Assert-Equal ($originalMigrationCount - 1) (Measure-Migration)
    
    & $pstep -Pop 2 -SqlServerName $server -Database $pstepTestDatabase -Path $pstepTestRoot
    Assert-LastProcessSucceeded
    Assert-Equal 0 ($error.Count)
    Assert-Equal ($originalMigrationCount - 2) (Measure-Migration)
    
    & $pstep -Pop 2 -SqlServerName $server -Database $pstepTestDatabase -Path $pstepTestRoot
    Assert-LastProcessSucceeded
    Assert-Equal 0 ($error.Count)
    Assert-Equal ($originalMigrationCount - 2) (Measure-Migration)
}

function Test-ShouldSupportPoppingMoreThanAvailableMigrations
{
    $migrationCount = Measure-Migration
    & $pstep -Pop ($migrationCount * 2) -SqlServerName $server -DAtabase $pstepTestDatabase -Path $pstepTestRoot
    Assert-LastProcessSucceeded
    Assert-Equal 0 ($error.Count)
    Assert-Equal 0 (Measure-Migration)
}


function Test-ShouldStopPoppingMigrationsIfOneGivesAnError
{
    Copy-Item -Path (Join-Path $pstepTestMigrationsDir Extras\*.ps1) -Destination $pstepTestMigrationsDir
    Remove-Item -Path (Join-Path $pstepTestMigrationsDir *_TableWithoutColumns.ps1)
    
    & $pstep -Push -SqlServer $server -Database $pstepTestDatabase -Path $pstepTestRoot
    Assert-LastProcessSucceeded
    Assert-True ($error.Count -eq 0)
    
    ('SecondTable','PushSucceedsPopFails','FourthTable') | ForEach-Object {
        Assert-True (_Test-Table -Name $_)
    }

    & $pstep -Pop (Measure-Migration) -SqlServer $server -Database $pstepTestDatabase -Path $pstepTestRoot
    Assert-LastProcessFailed
    
    Assert-True (_Test-Table -Name 'SecondTable')
    Assert-True (_Test-Table -Name 'PushSucceedsPopFails')
    Assert-False (_Test-Table -Name 'FourthTable')
        
}
