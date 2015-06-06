
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

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
    try
    {
        Clear-TestDatabase -Name $RTDatabase2Name
    }
    finally
    {
        Stop-RivetTest
    }
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
    Assert-Equal 'InvokeQuery' $rowsmigration[-4].Name
    Assert-Equal 'SecondTable' $rowsmigration[-3].Name
    Assert-Equal 'CreateObjectsFromFiles' $rowsmigration[-2].Name
    Assert-Equal 'CreateObjectInCustomDirectory' $rowsmigration[-1].Name

    Assert-NotNull $rowsactivity
    Assert-Equal 'Push' $rowsactivity[-4].Operation
    Assert-Equal 'InvokeQuery' $rowsactivity[-4].Name

    Assert-Equal 'Push' $rowsactivity[-3].Operation
    Assert-Equal 'SecondTable' $rowsactivity[-3].Name

    Assert-Equal 'Push' $rowsactivity[-2].Operation
    Assert-Equal 'CreateObjectsFromFiles' $rowsactivity[-2].Name

    Assert-Equal 'Push' $rowsactivity[-1].Operation
    Assert-Equal 'CreateObjectInCustomDirectory' $rowsactivity[-1].Name
}

function Test-ShouldPushMigrationsForMultipleDBs
{
    $rivetJson = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
    if( -not ($rivetJson | Get-Member -Name 'Databases') )
    {
        $rivetJson | Add-Member -MemberType NoteProperty -Name 'Databases' -Value @()
    }
    $rivetJson.Databases = @( $RTDatabaseName, $RTDatabase2Name )
    $rivetJson | ConvertTo-Json -Depth 500 | Set-Content -Path $RTConfigFilePath

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
    $migration | New-Migration -Name 'ShouldPushMigrationsForMultipleDBs' | Format-Table | Out-String | Write-Verbose -Verbose
    $migration | New-Migration -Name 'ShouldPushMigrationsForMultipleDBs' -DatabaseName $RTDatabase2Name | Format-Table | Out-String | Write-Verbose -Verbose

    Invoke-RTRivet -Push -Database $RTDatabaseName,$RTDatabase2Name -ConfigFilePath $RTConfigFilePath  | Format-Table | Out-String | Write-Verbose
        
    Assert-Migration 
    Assert-Migration -DatabaseName $RTDatabase2Name
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
    [CmdletBinding(DefaultParameterSetName='ByPath')]
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
        
        $DatabaseName = $RTDatabaseName
    )

    Set-StrictMode -Version 'Latest'
    
    if( $pscmdlet.ParameterSetName -eq 'ByPath' )
    {
        if( -not $Path )
        {
            $Path = Join-Path -Path $RTDatabasesRoot -ChildPath ('{0}\Migrations' -f $DatabaseName)
        }

        $count = 0
        Get-ChildItem $Path *.ps1 |
            Select-Object -ExpandProperty BaseName |
            Where-Object { $_ -match '^(\d+)_(.*)$' } |
            ForEach-Object { 
                $count++
                $id  = $matches[1] 
                $name = $matches[2]
                Assert-Migration -ID $id -Name $name -DatabaseName $DatabaseName
            }
        Assert-True ($count -gt 0)
        return
    }
    
    $migrationRow = Get-MigrationInfo -Name $Name -DatabaseName $DatabaseName
    Assert-IsNotNull $migrationRow ('Migration ''{0}'' not found in {1}.' -f $Name,$DatabaseName)

    Assert-True ($migrationRow -is [PsObject]) 'not a PsObject'
    Assert-Equal $id $migrationRow.ID $DatabaseName
    Assert-Equal $name $migrationRow.Name $DatabaseName
    Assert-Equal ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME) $migrationRow.Who $DatabaseName
    Assert-Equal $env:ComputerName $migrationRow.ComputerName $DatabaseName
    Assert-True ($migrationRow.AtUtc.AddMilliseconds(500) -gt $CreatedAfter) $DatabaseName
    $now = Get-SqlServerUtcDate
    Assert-True ($migrationRow.AtUtc.AddMilliseconds(-500) -lt $now) ('creation->migration: {0} migration->now: {1}' -f ($CreatedAfter - $migrationRow.AtUtc),($migrationRow.AtUTC - $now))
    
    if( $PassThru )
    {
        return $migrationRow
    }
}
