
. (Join-Path $TestDir Initialize-PstepTest.ps1 -Resolve)

$connection = $null

function Setup
{
    New-Database

    $connection = Connect-Database
}

function TearDown
{
    Disconnect-Database -Connection $connection
    
    Remove-Database
}

function Test-ShouldPushMigrations
{
    $createdAt = (Get-Date).ToUniversalTime()
    & $pstep -Push -SqlServerName $server -Database $database -Path $dbsRoot
    
    Get-ChildItem $migrationsDir *.ps1 | ForEach-Object {
        
        $id,$name = $_.BaseName -split '_'
        
        $query = 'select count(*) from sys.tables where name = ''{0}''' -f $name
        $tableCount = Invoke-Query -Query $query -Connection $connection -AsScalar
        Assert-Equal 1 $tableCount 'migration not run'
        
        Assert-Migration -ID $id -Name $name
    }
    
    # Make sure they are run in order.
    $query = 'select name from pstep.Migrations order by AtUtc'
    $rows = Invoke-Query -Query $query -Connection $connection
    Assert-NotNull $rows
    Assert-Equal 'InvokeQuery' $rows[0].Name
    Assert-Equal 'SecondTable' $rows[1].Name
    
    $createdBefore = (Get-Date).ToUniversalTime()
    & $pstep -Push -SqlServerName $server -Database $database -Path $dbsRoot
   
    $query = 'select name from pstep.Migrations order by AtUtc'
    $rows = Invoke-Query -Query $query -Connection $connection
    Assert-NotNull $rows
    Assert-Equal 2 $rows.Count
    $rows | ForEach-Object { Assert-True ($_.AtUtc -lt $createdBefore) }
    
}

function Test-ShouldPushSpecificMigrationByName
{
    $createdAfter = (Get-Date).ToUniversalTime()
    Get-ChildItem $migrationsDir *.ps1 | 
        Select-Object -First 1 |
        ForEach-Object {
            $id,$name = $_.BaseName -split '_'
            
            & $pstep -Push -Name $name -SqlServerName $server -Database $database -Path $dbsRoot
            
            Assert-Migration -ID $id -Name $name -CreatedAfter $CreatedAfter
        }
        
    $count = Invoke-Query -Query 'select count(*) from pstep.Migrations' -Connection $connection -AsScalar
    Assert-Equal 1 $count 'applied too many migrations'
}

function Test-ShouldPushSpecificMigrationWithWildcard
{
    $createdAfter = (Get-Date).ToUniversalTime()
    
    & $pstep -Push -Name 'Invoke*' -SqlServerName $server -Database $database -Path $dbsRoot
    
    $migration = Get-ChildItem $migrationsDir *_Invoke*.ps1
    $id,$name = $migration.BaseName -split '_'
    Assert-Migration -ID $id -Name $name -CreatedAfter $CreatedAfter
        
    $count = Invoke-Query -Query 'select count(*) from pstep.Migrations' -Connection $connection -AsScalar
    Assert-Equal 1 $count 'applied too many migrations'
}

function Test-ShouldNotReapplyASpecificMigration
{
    $createdAfter = (Get-Date).ToUniversalTime()
    Get-ChildItem $migrationsDir *.ps1 | 
        Select-Object -First 1 |
        ForEach-Object {
            $id,$name = $_.BaseName -split '_'
            
            & $pstep -Push -Name $name -SqlServerName $server -Database $database -Path $dbsRoot
            
            Assert-Migration -ID $id -Name $name -CreatedAfter $CreatedAfter
            
            $createdBefore = (Get-Date).ToUniversalTime()
            
            & $pstep -Push -Name $name -SqlServerName $server -Database $database -Path $dbsRoot

            $row = Assert-Migration -ID $id -Name $name -CreatedAfter $CreatedAfter -PassThru
            Assert-True ($row.AtUtc -lt $createdBefore)
        }
        
    $count = Invoke-Query -Query 'select count(*) from pstep.Migrations' -Connection $connection -AsScalar
    Assert-Equal 1 $count 'applied too many migrations'}

function Assert-Migration
{
    param(
        $ID,
        $Name,
        $CreatedAfter,
        
        [Switch]
        $PassThru
    )
    
    $query = 'select * from pstep.Migrations where name = ''{0}''' -f $Name
    $migrationRow = Invoke-Query -Query $query -Connection $connection
    Assert-IsNotNull $migrationRow
    Assert-True ($migrationRow -is [PsObject]) 'not a PsObject'
    Assert-Equal $id $migrationRow.ID
    Assert-Equal $name $migrationRow.Name
    Assert-Equal ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME) $migrationRow.Who
    Assert-Equal $env:ComputerName $migrationRow.ComputerName
    Assert-True ($migrationRow.AtUtc -gt $CreatedAfter)
    Assert-True ($migrationRow.AtUtc -lt ((Get-Date).ToUniversalTime()))
    
    if( $PassThru )
    {
        return $migrationRow
    }
}