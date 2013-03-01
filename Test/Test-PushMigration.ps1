
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
    
    $migrationScripts = Get-ChildItem $migrationsDir *.ps1 
    
    $migrationScripts | ForEach-Object {
        
        $id,$name = $_.BaseName -split '_'
        
        Assert-Migration -ID $id -Name $name
    }
    
    Assert-True (_Test-Table -Name 'InvokeQuery')
    Assert-True (_Test-Table -Name 'SecondTable')
    Assert-True (_Test-DBObject -StoredProcedure 'PstepTestSproc')
    Assert-True (_Test-DBObject -ScalarFunction 'PstepTestFunction') 'user-defined function not created'
    Assert-True (_Test-DBObject -View 'Migrators') 'view not created'
    Assert-True (_Test-DBObject -ScalarFunction 'MiscellaneousObject') 'the miscellaneous function not created'
    
    # Make sure they are run in order.
    $query = 'select name from pstep.Migrations order by AtUtc'
    $rows = Invoke-Query -Query $query -Connection $connection
    Assert-NotNull $rows
    Assert-Equal 'InvokeQuery' $rows[0].Name
    Assert-Equal 'SecondTable' $rows[1].Name
    Assert-Equal 'CreateObjectsFromFiles' $rows[2].Name
    
    $createdBefore = (Get-Date).ToUniversalTime()
    & $pstep -Push -SqlServerName $server -Database $database -Path $dbsRoot
   
    $query = 'select name from pstep.Migrations order by AtUtc'
    $rows = Invoke-Query -Query $query -Connection $connection
    Assert-NotNull $rows
    Assert-Equal $migrationScripts.Count $rows.Count
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
    Assert-Equal 1 $count 'applied too many migrations'

}

function Test-ShouldStopPushingMigrationsIfOneGivesAnError
{
    Copy-Item -Path (Join-Path $migrationsDir Extras\*.ps1) -Destination $migrationsDir
    
    & $pstep -Push -SqlServer $server -Database $database -Path $dbsRoot
    Assert-LastProcessFailed
    Assert-True ($error.Count -gt 0)
    
    ('TableWithoutColumnsWithColumn','TableWithoutColumns','FourthTable') | ForEach-Object {
        $query = 'select count(*) from sys.tables where name = ''{0}''' -f $_
        $tableCount = Invoke-Query -Query $query -Connection $connection -AsScalar
        Assert-Equal 0 $tableCount ('table {0} created' -f $_)
    }
    
    $query = 'select count(*) from InvokeQuery'
    $rowCount = Invoke-Query -Query $query -Connection $connection -AsScalar
    Assert-Equal 0 $tableCount 'insert statements not rolled back'

    ('TableWithoutColumns','FourthTable') | ForEach-Object {
        $query = 'select count(*) from pstep.Migrations where name = ''{0}''' -f $_
        $rowCount = Invoke-Query -Query $query -Connection $connection -AsScalar
        Assert-Equal 0 $rowCount ('migration {0} recorded' -f $_)
    }
}

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