
. (Join-Path $TestDir Initialize-PstepTest.ps1 -Resolve)

$connection = $null

function Setup
{
    New-Database

    $connection = Connect-Database
    
    Get-ChildItem $migrationsDir *.ps1 | 
        Sort-Object BaseName | 
        Select-Object -Skip 2 | 
        Remove-Item
    
    & $pstep -Push -SqlServerName $server -Database $database -Path $dbsRoot
    
    Assert-Equal 2 (Measure-Migration)
}

function TearDown
{
    Disconnect-Database -Connection $connection
    
    Remove-Database
}

function Test-ShouldPopThenPushTopMigration
{
    $createdAt = Invoke-Query -Query 'select create_date from sys.tables where name = ''SecondTable''' -Connection $connection -AsScalar
    $migratedAt = Invoke-Query -Query 'select AtUtc from pstep.Migrations where name = ''SecondTable''' -Connection $connection -AsScalar
    
    & $pstep -Redo -SqlServerName $server -Database $database -Path $dbsRoot
    
    $redoCreatedAt = Invoke-Query -Query 'select create_date from sys.tables where name = ''SecondTable''' -Connection $connection -AsScalar
    Assert-NotNull $redoCreatedAt
    $redoMigratedAt = Invoke-Query -Query 'select AtUtc from pstep.Migrations where name = ''SecondTable''' -Connection $connection -AsScalar
    Assert-NotNull $redoMigratedAt
    
    Assert-True ($createdAt -lt $redoCreatedAt)
    Assert-True ($migratedAt -lt $redoMigratedAt)
}