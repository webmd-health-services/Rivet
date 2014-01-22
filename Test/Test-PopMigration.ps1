$migration1 = $null
$migration2 = $null
$migration3 = $null
$migration4 = $null

function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'PopMigration' 
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
'@ | New-Migration -Name 'Migration1'

    $migration2 = @'
function Push-Migration
{
    Add-Table 'Migration2' { int ID -Identity }
}
function Pop-Migration 
{
    Remove-Table 'Migration2'
}
'@ | New-Migration -Name 'Migration2'

    $migration3 = @'
function Push-Migration
{
    Add-Table 'Migration3' { int ID -Identity }
}
function Pop-Migration 
{
    Remove-Table 'Migration3'
}
'@ | New-Migration -Name 'Migration3'

    $migration4 = @'
function Push-Migration
{
    Add-Table 'Migration4' { int ID -Identity }
}
function Pop-Migration 
{
    Remove-Table 'Migration4'
}
'@ | New-Migration -Name 'Migration4'

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
}

function Test-ShouldWriteToActivityTableOnPop
{
    $migrationCount = Measure-Migration
    Assert-True ($migrationCount -gt 1)

    Invoke-Rivet -Pop
    Assert-LastProcessSucceeded

    Assert-Equal ($migrationCount-1) (Measure-Migration)

    $rows = Get-ActivityInfo

    Assert-Equal 'Pop' $rows[4].Operation
    Assert-Equal 'Migration4' $rows[4].Name
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
    @'
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
'@ | New-Migration -Name 'PopFails'
    
    Invoke-Rivet -Push
    Assert-LastProcessSucceeded
    Assert-True ($error.Count -eq 0)
    
    Invoke-Rivet -Pop (Measure-Migration) -ErrorAction SilentlyContinue -ErrorVariable rivetError

    Assert-NotNull $rivetError
    Assert-Like $rivetError[0] '*cannot drop the table*'
    
    Assert-True (Test-Table -Name 'Migration5')
    Assert-True (Test-Table -Name 'Migration4')
    Assert-True (Test-Table -Name 'Migration3')
    Assert-True (Test-Table -Name 'Migration2')
    Assert-True (Test-Table -Name 'Migration1')
}

function Test-ShouldPopByName
{
    Invoke-Rivet -Pop 'Migration1'

    Assert-True (Test-Table -Name 'Migration4')
    Assert-True (Test-Table -Name 'Migration3')
    Assert-True (Test-Table -Name 'Migration2')
    Assert-False (Test-Table -Name 'Migration1')
}

function Test-ShouldPopByNameWithWildcard
{
    Invoke-Rivet -Pop 'Migration*'

    Assert-False (Test-Table -Name 'Migration4')
    Assert-False (Test-Table -Name 'Migration3')
    Assert-False (Test-Table -Name 'Migration2')
    Assert-False (Test-Table -Name 'Migration1')
}


function Test-ShouldPopByNameWithNoMatch
{
    $Error.Clear()
    Invoke-Rivet -Pop 'Blah' -ErrorAction SilentlyContinue
    Assert-Equal 1 $Error.Count
    Assert-Like $Error[0].Exception.Message '*not found*'

    Assert-True (Test-Table -Name 'Migration4')
    Assert-True (Test-Table -Name 'Migration3')
    Assert-True (Test-Table -Name 'Migration2')
    Assert-True (Test-Table -Name 'Migration1')
}

function Test-ShouldPopByID
{
    $name = $migration1.BaseName.Substring(0,14)
    Invoke-Rivet -Pop $name
    Assert-Table -Name 'Migration4'
    Assert-Table -Name 'Migration3'
    Assert-Table -Name 'Migration2'
    Assert-False (Test-Table -Name 'Migration1')
}

function Test-ShouldPopByIDWithWildcard
{
    $name = '{0:yyyyMMdd}*' -f (Get-Date)
    Invoke-Rivet -Pop $name
    Assert-False (Test-Table -Name 'Migration4')
    Assert-False (Test-Table -Name 'Migration3')
    Assert-False (Test-Table -Name 'Migration2')
    Assert-False (Test-Table -Name 'Migration1')
}