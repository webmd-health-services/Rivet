
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

$migration1 = $null
$migration2 = $null
$migration3 = $null
$migration4 = $null

function Start-Test
{
    Start-RivetTest

    $migration1 = @'
function Push-Migration
{
    Add-Table 'Migration1' { int ID -Identity }
}
function Pop-Migration 
{
    Remove-Table 'Migration1'
}
'@ | New-TestMigration -Name 'Migration1'

    $migration2 = @'
function Push-Migration
{
    Add-Table 'Migration2' { int ID -Identity }
}
function Pop-Migration 
{
    Remove-Table 'Migration2'
}
'@ | New-TestMigration -Name 'Migration2'

    $migration3 = @'
function Push-Migration
{
    Add-Table 'Migration3' { int ID -Identity }
}
function Pop-Migration 
{
    Remove-Table 'Migration3'
}
'@ | New-TestMigration -Name 'Migration3'

    $migration4 = @'
function Push-Migration
{
    Add-Table 'Migration4' { int ID -Identity }
}
function Pop-Migration 
{
    Remove-Table 'Migration4'
}
'@ | New-TestMigration -Name 'Migration4'

    Invoke-RTRivet -Push
    
    $expectedCount = Measure-MigrationScript
    Assert-Equal $expectedCount (Measure-Migration)
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldPopAllMigrations
{
    $migrationCount = Measure-Migration
    Assert-True ($migrationCount -gt 1)
    
    Invoke-RTRivet -Pop $migrationCount
    Assert-LastProcessSucceeded
    
    Assert-Equal 0 (Measure-Migration)
    
    Get-MigrationScript | ForEach-Object {
        
        $id,$name = $_.BaseName -split '_'
        
        Assert-False (Test-Table -Name $name)
    }
}

function Test-ShouldWriteToActivityTableOnPop
{
    $migrationCount = Measure-Migration
    Assert-True ($migrationCount -gt 1)

    Invoke-RTRivet -Pop
    Assert-LastProcessSucceeded

    Assert-Equal ($migrationCount-1) (Measure-Migration)

    $rows = Get-ActivityInfo

    Assert-Equal 'Pop' $rows[-1].Operation
    Assert-Equal 'Migration4' $rows[-1].Name
}

function Test-ShouldPopSpecificNumberOfDatabaseMigrations
{
    $rivetCount = Measure-Migration
    Assert-True ($rivetCount -gt 1)

    Invoke-RTRivet -Pop 2
        
    Assert-Equal ($rivetCount - 2) (Measure-Migration)
}

function Test-ShouldPopOneMigrationByDefault
{
    $totalMigrations = Measure-Migration
    
    Invoke-RTRivet -Pop
    
    Assert-Equal ($totalMigrations - 1) (Measure-Migration)
    
    $firstMigration = Get-MigrationScript | Select-Object -First 1
                        
    $id,$name = $firstMigration.BaseName -split '_'
    Assert-True (Test-Table -Name $name)
}

function Test-ShouldNotRePopMigrations
{
    $originalMigrationCount = Measure-Migration
    Invoke-RTRivet -Pop
    Assert-LastProcessSucceeded
    Assert-NoError
    Assert-Equal ($originalMigrationCount - 1) (Measure-Migration)
    
    Invoke-RTRivet -Pop 2
    Assert-LastProcessSucceeded
    Assert-NoError
    Assert-Equal ($originalMigrationCount - 2) (Measure-Migration)
    
    Invoke-RTRivet -Pop 2
    Assert-LastProcessSucceeded
    Assert-NoError
    Assert-Equal ($originalMigrationCount - 2) (Measure-Migration)
}

function Test-ShouldSupportPoppingMoreThanAvailableMigrations
{
    $migrationCount = Measure-Migration
    Invoke-RTRivet -Pop ($migrationCount * 2) 
    Assert-LastProcessSucceeded
    Assert-NoError
    Assert-Equal 0 (Measure-Migration)
}


function Test-ShouldStopPoppingMigrationsIfOneGivesAnError
{
    $migrationFileInfo = @'
function Push-Migration
{
    Add-Table 'Migration5' {
        int 'ID' -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'Migration38'
}
'@ | New-TestMigration -Name 'PopFails'
    
    try
    {
        Invoke-RTRivet -Push
        Assert-LastProcessSucceeded
        Assert-NoError
    
        Invoke-RTRivet -Pop (Measure-Migration) -ErrorAction SilentlyContinue

        Assert-Error -Index 1 -Regex 'cannot drop the table'
    
        Assert-True (Test-Table -Name 'Migration5')
        Assert-True (Test-Table -Name 'Migration4')
        Assert-True (Test-Table -Name 'Migration3')
        Assert-True (Test-Table -Name 'Migration2')
        Assert-True (Test-Table -Name 'Migration1')
    }
    finally
    {
        @'
function Push-Migration
{
    Add-Table 'Migration5' {
        int 'ID' -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'Migration5'
}
'@ | Set-Content -Path $migrationFileInfo
    }
}

function Test-ShouldPopByName
{
    Invoke-RTRivet -Pop 'Migration1'

    Assert-True (Test-Table -Name 'Migration4')
    Assert-True (Test-Table -Name 'Migration3')
    Assert-True (Test-Table -Name 'Migration2')
    Assert-False (Test-Table -Name 'Migration1')
}

function Test-ShouldPopByNameWithWildcard
{
    Invoke-RTRivet -Pop 'Migration*'

    Assert-False (Test-Table -Name 'Migration4')
    Assert-False (Test-Table -Name 'Migration3')
    Assert-False (Test-Table -Name 'Migration2')
    Assert-False (Test-Table -Name 'Migration1')
}


function Test-ShouldPopByNameWithNoMatch
{
    Invoke-RTRivet -Pop 'Blah' -ErrorAction SilentlyContinue
    Assert-Error -Last 'not found'

    Assert-True (Test-Table -Name 'Migration4')
    Assert-True (Test-Table -Name 'Migration3')
    Assert-True (Test-Table -Name 'Migration2')
    Assert-True (Test-Table -Name 'Migration1')
}

function Test-ShouldPopByID
{
    $name = $migration1.BaseName.Substring(0,14)
    Invoke-RTRivet -Pop $name
    Assert-Table -Name 'Migration4'
    Assert-Table -Name 'Migration3'
    Assert-Table -Name 'Migration2'
    Assert-False (Test-Table -Name 'Migration1')
}

function Test-ShouldPopByIDWithWildcard
{
    $name = '{0}*' -f $RTTimestamp.ToString().Substring(0,8)
    Invoke-RTRivet -Pop $name
    Assert-False (Test-Table -Name 'Migration4')
    Assert-False (Test-Table -Name 'Migration3')
    Assert-False (Test-Table -Name 'Migration2')
    Assert-False (Test-Table -Name 'Migration1')
}

function Test-ShouldPopAll
{
    Invoke-RTRivet -Pop -All
    Assert-False (Test-Table -Name 'Migration4')
    Assert-False (Test-Table -Name 'Migration3')
    Assert-False (Test-Table -Name 'Migration2')
    Assert-False (Test-Table -Name 'Migration1')
}

function Test-ShouldConfirmPoppingAnothersMigration
{
    Invoke-RivetTestQuery -Query 'update [rivet].[Migrations] set Who = ''LittleLionMan'''

    Invoke-RTRivet -Pop -All -Force
    Assert-False (Test-Table 'Migration4')
    Assert-False (Test-Table 'Migration3')
    Assert-False (Test-Table 'Migration2')
    Assert-False (Test-Table 'Migration1')
}

function Test-ShouldConfirmPoppingOldMigrations
{
    Invoke-RivetTestQuery -Query 'update [rivet].[Migrations] set AtUtc = dateadd(minute, -21, AtUtc)'

    Invoke-RTRivet -Pop -All -Force
    Assert-False (Test-Table 'Migration4')
    Assert-False (Test-Table 'Migration3')
    Assert-False (Test-Table 'Migration2')
    Assert-False (Test-Table 'Migration1')
}
