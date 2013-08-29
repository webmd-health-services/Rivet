
function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldPushMigrations
{
    $createdAt = (Get-Date).ToUniversalTime()
    Invoke-Rivet -Push
    
    $migrationScripts = Get-MigrationScript
    
    $migrationScripts | ForEach-Object {
        
        $id,$name = $_.BaseName -split '_'
        
        Assert-Migration -ID $id -Name $name
    }
    
    Assert-True (Test-Table -Name 'InvokeQuery')
    Assert-True (Test-Table -Name 'SecondTable')
    Assert-True (Test-DatabaseObject -StoredProcedure 'RivetTestSproc')
    Assert-True (Test-DatabaseObject -ScalarFunction 'RivetTestFunction') 'user-defined function not created'
    Assert-True (Test-DatabaseObject -View 'Migrators') 'view not created'
    Assert-True (Test-DatabaseObject -ScalarFunction 'MiscellaneousObject') 'the miscellaneous function not created'
    Assert-True (Test-DatabaseObject -ScalarFunction 'ObjectMadeWithRelativePath') 'object specified with relative path to Invoke-SqlScript not created'

    # Make sure they are run in order.
    $rows = Get-MigrationInfo
    Assert-NotNull $rows
    Assert-Equal 'InvokeQuery' $rows[0].Name
    Assert-Equal 'SecondTable' $rows[1].Name
    Assert-Equal 'CreateObjectsFromFiles' $rows[2].Name
    
    $createdBefore = Get-SqlServerUtcDate
    Invoke-Rivet -Push
   
    $rows = Get-MigrationInfo
    Assert-NotNull $rows
    Assert-Equal $migrationScripts.Count $rows.Count
    $rows | ForEach-Object { Assert-True ($_.AtUtc -lt $createdBefore) }
}

function Test-ShouldPushMigrationsForMultipleDBs
{
    $timestamp = '{0:yyyyMMddHHss}' -f (Get-Date)
    $db1Name = 'PushMigration{0}' -f $timestamp
    $db2Name = 'PushMigration{0}' -f $timestamp
    $migrationFileName = '20130703152600_CreateTable.ps1'
    $tree = @'
+ {0}
  + Migrations
    * {1}
+ {2}
  + Migrations
    * {1}
'@ -f $db1Name,$migrationFileName,$db2Name

    $tempDir = New-TempDirectoryTree -Tree $tree -Prefix 'Rivet.Push-Migration'

    $migration = @'
        function Push-Migration 
        {
            Add-Table Table1 {
                New-Column 'id' -Int -Identity
            }
        }

        function Pop-Migration
        {
            Remove-Table 'Table1'
        }
'@

    $configFilePath = Join-Path -Path $tempDir -ChildPath 'rivet.json'
    @"
{
    SqlServerName: "$($RTServer.Replace('\','\\'))",
    DatabasesRoot: "$($tempDir.FullName.Replace('\','\\'))"
}
"@ | Set-Content -Path $configFilePath

    $db1MigrationsDir = Join-Path $tempDir $db1Name\Migrations
    $migration | Out-File (Join-Path $db1MigrationsDir $migrationFileName) -Encoding OEM

    $db2MigrationsDir = Join-Path $tempDir $db2Name\Migrations
    $migration | Out-File (Join-Path $db2MigrationsDir $migrationFileName) -Encoding OEM

    New-Database -Name $db1Name
    $db1Conn = New-SqlConnection -Database $db1Name

    New-Database -Name $db2Name
    $db2Conn = New-SqlConnection -Database $db2Name
    
    try
    {
        Invoke-Rivet -Push -Database $db1Name,$db2Name -ConfigFilePath $configFilePath
        
        Assert-Migration -Path $db1MigrationsDir -Connection $db1Conn
        Assert-Migration -Path $db2MigrationsDir -Connection $db2Conn
    }
    finally
    {
        Remove-RivetTestDatabase -Name $db1Name
        $db1Conn.Close()

        Remove-RivetTestDatabase -Name $db2Name
        $db2Conn.Close()
    }
}

function Test-ShouldPushSpecificMigrationByName
{
    $createdAfter = (Get-Date).ToUniversalTime()
    Get-MigrationScript | 
        Select-Object -First 1 |
        ForEach-Object {
            $id,$name = $_.BaseName -split '_'
            
            Invoke-Rivet -Push $Name
            
            Assert-Migration -ID $id -Name $name -CreatedAfter $CreatedAfter
        }
        
    $count = Measure-Migration
    Assert-Equal 1 $count 'applied too many migrations'
}

function Test-ShouldPushSpecificMigrationWithWildcard
{
    $createdAfter = (Get-Date).ToUniversalTime()
    
    Invoke-Rivet -Push 'Invoke*'
    
    $migration = Get-MigrationScript | Where-Object { $_.Name -like '*_Invoke*.ps1' }
    $id,$name = $migration.BaseName -split '_'
    Assert-Migration -ID $id -Name $name -CreatedAfter $CreatedAfter
        
    $count = Measure-Migration
    Assert-Equal 1 $count 'applied too many migrations'
}

function Test-ShouldNotReapplyASpecificMigration
{
    $createdAfter = (Get-Date).ToUniversalTime()
    Get-MigrationScript | 
        Select-Object -First 1 |
        ForEach-Object {
            $id,$name = $_.BaseName -split '_'
            
            Invoke-Rivet -Push $name
            
            Assert-Migration -ID $id -Name $name -CreatedAfter $CreatedAfter
            
            $createdBefore = Get-SqlServerUtcDate

            Invoke-Rivet -Push $name            

            $row = Assert-Migration -ID $id -Name $name -CreatedAfter $CreatedAfter -PassThru
            Assert-True ($row.AtUtc -lt $createdBefore)
        }
        
    $count = Measure-Migration 
    Assert-Equal 1 $count 'applied too many migrations'

}

function Test-ShouldStopPushingMigrationsIfOneGivesAnError
{
    $script = Get-MigrationScript | Select-Object -First 1
    $migrationDir = Split-Path -Parent -Path $script.FullName
    Copy-Item -Path (Join-Path $migrationDir Extras\*.ps1) -Destination $migrationDir
    
    Invoke-Rivet -Push -ErrorAction SilentlyContinue -ErrorVariable rivetError
    Assert-True ($rivetError.Count -gt 0)
    
    ('TableWithoutColumnsWithColumn','TableWithoutColumns','FourthTable') | ForEach-Object {
        Assert-False (Test-Table -Name $_) ('table {0} created' -f $_)
    }
    
    $query = 'select count(*) from InvokeQuery'
    $rowCount = Invoke-RivetTestQuery -Query $query -AsScalar
    Assert-Equal 0 $rowCount 'insert statements not rolled back'

    ('TableWithoutColumns','FourthTable') | ForEach-Object {
        $migration = Get-MigrationInfo -Name $_
        Assert-Null $migration
    }
}

function Test-ShouldFailIfMigrationNameDoesNotExist
{
    $Error.Clear()
    Invoke-Rivet -Push 'AMigrationWhichDoesNotExist' -ErrorAction SilentlyContinue

    Assert-GreaterThan $Error.Count 0
    Assert-Like $Error[0] '*not found*'
}

function Get-SqlServerUtcDate
{
    Invoke-RivetTestQuery -Query 'select getutcdate()' -AsScalar 
}

function Assert-Migration
{
    param(
        [Parameter(ParameterSetName='ByID')]
        $ID,

        [Parameter(ParameterSetName='ByID')]
        $Name,

        [Parameter(ParameterSetName='ByID')]
        $CreatedAfter,
        
        [Parameter(ParameterSetName='ByPath')]
        $Path,
        
        [Switch]
        $PassThru,
        
        $Connection
    )
    
    $connParam = @{ }
    if( $Connection )
    {
        $connParam.Connection = $Connection
    }

    if( $pscmdlet.ParameterSetName -eq 'ByPath' )
    {
        $count = 0
        Get-ChildItem $Path *.ps1 |
            Select-Object -ExpandProperty BaseName |
            Where-Object { $_ -match '^(\d+)_(.*)$' } |
            ForEach-Object { 
                $count++
                $id  = $matches[1] 
                $name = $matches[2]
                Assert-Migration -ID $id -Name $name @connParam
            }
        Assert-True ($count -gt 0)
        return
    }
    
    $migrationRow = Get-MigrationInfo -Name $Name @connParam
    Assert-IsNotNull $migrationRow
    Assert-True ($migrationRow -is [PsObject]) 'not a PsObject'
    Assert-Equal $id $migrationRow.ID
    Assert-Equal $name $migrationRow.Name
    Assert-Equal ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME) $migrationRow.Who
    Assert-Equal $env:ComputerName $migrationRow.ComputerName
    Assert-True ($migrationRow.AtUtc -gt $CreatedAfter)
    $now = Get-SqlServerUtcDate
    Assert-True ($migrationRow.AtUtc -le $now) ('{0} >= {1}' -f $migrationRow.AtUtc,$now)
    
    if( $PassThru )
    {
        return $migrationRow
    }
}
