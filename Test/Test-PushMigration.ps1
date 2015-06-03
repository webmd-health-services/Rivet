
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'RivetTest' 

function Start-Test
{
    Start-RivetTest

    @'
function Push-Migration()
{
    Add-Table 'InvokeQuery' {
        int 'id' -NotNull
    }
}

function Pop-Migration()
{
    Remove-Table 'InvokeQuery'
}
'@ | New-Migration -Name 'InvokeQuery'

    @'
function Push-Migration()
{
    Add-Table 'secondTable' {
        int 'id' -NotNull
    }
}

function Pop-Migration()
{
    Remove-Table 'secondTable'
}
'@ | New-Migration -Name 'SecondTable'

    @'
function Push-Migration()
{
    Add-StoredProcedure -Name RivetTestSproc -Definition 'as SELECT FirstName, LastName FROM dbo.Person;'
    Add-UserDefinedFunction -Name RivetTestFunction -Definition '(@Number decimal(4,1)) returns decimal(12,3) as begin return(@Number * @Number) end'
    Add-View -Name Migrators -Definition "AS SELECT DISTINCT Name FROM rivet.Migrations"
}

function Pop-Migration()
{
    Remove-View -Name Migrators
    Remove-UserDefinedFunction -Name RivetTestFunction
    Remove-StoredProcedure -Name RivetTestSproc
}
'@ | New-Migration -Name 'CreateObjectsFromFiles'

    @'

function Push-Migration()
{
    $miscScriptPath = Join-Path $DBMigrationsRoot '..\MiscellaneousObject.sql'
    Invoke-SqlScript -Path $miscScriptPath
    Invoke-SqlScript -Path ..\ObjectMadeWithRelativePath.sql
}

function Pop-Migration()
{
    Remove-UserDefinedFunction -Name MiscellaneousObject
    Remove-UserDefinedFunction -Name ObjectMadeWithRelativePath
}
'@ | New-Migration -Name 'CreateObjectInCustomDirectory'

    $miscellaneousObjectPath = Join-Path -Path $RTDatabaseMigrationRoot -ChildPath '..\MiscellaneousObject.sql'
    @'
CREATE FUNCTION MiscellaneousObject
(
)
RETURNS datetime
AS
BEGIN

	return GetDate()
	
END
GO
'@ | Set-Content -Path $miscellaneousObjectPath

    $objectMadeWithRelativePathath = Join-Path -Path $RTDatabaseMigrationRoot -ChildPath '..\ObjectMadeWithRelativePath.sql'
    @'
CREATE FUNCTION ObjectMadeWithRelativePath
(
)
RETURNS datetime
AS
BEGIN

	return GetDate()
	
END
GO
'@ | Set-Content -Path $objectMadeWithRelativePathath
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldPushMigrations
{
    $createdAt = (Get-Date).ToUniversalTime()
    Invoke-RTRivet -Push
    
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
    Invoke-RTRivet -Push
   
    $rows = Get-MigrationInfo
    Assert-NotNull $rows
    Assert-Equal $migrationScripts.Count $rows.Count
    $rows | ForEach-Object { Assert-True ($_.AtUtc.AddMilliseconds(-500) -lt $createdBefore) }
}

function Test-ShouldPushMigrationAndAddToActivityTable
{
    Invoke-RTRivet -Push

    $migrationScripts = Get-MigrationScript
    
    $migrationScripts | ForEach-Object {
        
        $id,$name = $_.BaseName -split '_'
        
        Assert-Migration -ID $id -Name $name
    }

    Assert-True (Test-Table -Schema 'rivet' -Name 'Migrations')
    Assert-True (Test-Table -Schema 'rivet' -Name 'Activity')
    
    $rowsmigration = Get-MigrationInfo
    $rowsactivity = Get-ActivityInfo 

    Assert-NotNull $rowsmigration
    Assert-Equal 'InvokeQuery' $rowsmigration[0].Name
    Assert-Equal 'SecondTable' $rowsmigration[1].Name
    Assert-Equal 'CreateObjectsFromFiles' $rowsmigration[2].Name

    Assert-NotNull $rowsactivity
    Assert-Equal 'Push' $rowsactivity[0].Operation
    Assert-Equal 'InvokeQuery' $rowsactivity[0].Name

    Assert-Equal 'Push' $rowsactivity[1].Operation
    Assert-Equal 'SecondTable' $rowsactivity[1].Name

    Assert-Equal 'Push' $rowsactivity[2].Operation
    Assert-Equal 'CreateObjectsFromFiles' $rowsactivity[2].Name
}

function Test-ShouldPushMigrationsForMultipleDBs
{
    $createdAfter = (Get-Date).ToUniversalTime()

    $db1Name = 'PushMigration1'
    $db2Name = 'PushMigration2'
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
                Int 'id' -Identity
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

    $db1Conn = $null
    $db2Conn = $null
    try
    {
        Invoke-RTRivet -Push -Database $db1Name,$db2Name -ConfigFilePath $configFilePath  | Format-Table | Out-String | Write-Verbose
        
        $db1Conn = New-SqlConnection -Database $db1Name
        $db2Conn = New-SqlConnection -Database $db2Name

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
    #Start-Sleep -Seconds 1
    Get-MigrationScript | 
        Select-Object -First 1 |
        ForEach-Object {
            $id,$name = $_.BaseName -split '_'
            
            Invoke-RTRivet -Push $Name
            
            Assert-Migration -ID $id -Name $name -CreatedAfter $CreatedAfter
        }
        
    $count = Measure-Migration
    Assert-Equal 1 $count 'applied too many migrations'
}

function Test-ShouldPushSpecificMigrationWithWildcard
{
    $createdAfter = (Get-Date).ToUniversalTime()
    
    Invoke-RTRivet -Push 'Invoke*'
    
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
            
            Invoke-RTRivet -Push $name
            
            Assert-Migration -ID $id -Name $name -CreatedAfter $CreatedAfter
            
            $createdBefore = Get-SqlServerUtcDate

            Invoke-RTRivet -Push $name            

            $row = Assert-Migration -ID $id -Name $name -CreatedAfter $CreatedAfter -PassThru
            Assert-True ($row.AtUtc.AddMilliseconds(-500) -lt $createdBefore)
        }
        
    $count = Measure-Migration 
    Assert-Equal 1 $count 'applied too many migrations'

}

function Test-ShouldStopPushingMigrationsIfOneGivesAnError
{
    @'
function Push-Migration()
{
    Add-Table 'TableWithoutColumns' {
    }
}

function Pop-Migration()
{
    Remove-Table 'TableWithoutColumns'
}
'@ | New-Migration -Name 'AddTableWithNOColumns'

    Invoke-RTRivet -Push -ErrorAction SilentlyContinue -ErrorVariable rivetError
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
    Invoke-RTRivet -Push 'AMigrationWhichDoesNotExist' -ErrorAction SilentlyContinue
    Assert-Error -Last 'not found'
}

function Get-SqlServerUtcDate
{
    Invoke-RivetTestQuery -Query 'select cast(getutcdate() as datetime2)' -AsScalar 
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
    if( $Connection )
    {
        Assert-IsNotNull $migrationRow ('Migration ''{0}'' not found in {1}.{2}.' -f $Name,$Connection.DataSource,$Connection.Database)
    }
    else
    {
        Assert-IsNotNull $migrationRow ('Migration ''{0}'' not found.')
    }

    Assert-True ($migrationRow -is [PsObject]) 'not a PsObject'
    Assert-Equal $id $migrationRow.ID
    Assert-Equal $name $migrationRow.Name
    Assert-Equal ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME) $migrationRow.Who
    Assert-Equal $env:ComputerName $migrationRow.ComputerName
    Assert-True ($migrationRow.AtUtc.AddMilliseconds(500) -gt $CreatedAfter)
    $now = Get-SqlServerUtcDate
    Assert-True ($migrationRow.AtUtc.AddMilliseconds(-500) -lt $now) ('creation->migration: {0} migration->now: {1}' -f ($CreatedAfter - $migrationRow.AtUtc),($migrationRow.AtUTC - $now))
    
    if( $PassThru )
    {
        return $migrationRow
    }
}
