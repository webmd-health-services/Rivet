
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

    $script:testStartedAt = $null

    function Assert-Migration
    {
        [CmdletBinding(DefaultParameterSetName='ByPath')]
        param(
            [Parameter(ParameterSetName='ByID')]
            $ID,

            [Parameter(ParameterSetName='ByID')]
            $Name,

            [Parameter(ParameterSetName='ByID')]
            $CreatedAfter = $script:testStartedAt,

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
            ($count -gt 0) | Should -BeTrue
            return
        }

        $migrationRow = Get-MigrationInfo -Name $Name -DatabaseName $DatabaseName
        $migrationRow | Should -Not -BeNullOrEmpty -Because ('Migration ''{0}'' not found in {1}.' -f $Name,$DatabaseName)

        ($migrationRow -is [PsObject]) | Should -BeTrue
        $migrationRow.ID | Should -Be $id
        $migrationRow.Name | Should -Be $name
        $migrationRow.Who | Should -Be ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME)
        $migrationRow.ComputerName | Should -Be $env:ComputerName
        ($migrationRow.AtUtc.AddMilliseconds(500) -gt $CreatedAfter) | Should -BeTrue
        $now = Get-SqlServerUtcDate
        ($migrationRow.AtUtc.AddMilliseconds(-500) -lt $now) | Should -BeTrue

        if( $PassThru )
        {
            return $migrationRow
        }
    }

    function Get-SqlServerUtcDate
    {
        Invoke-RivetTestQuery -Query 'select cast(getutcdate() as datetime2)' -AsScalar
    }
}

Describe 'Push-Migration' {
    BeforeEach {
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
'@ | New-TestMigration -Name 'InvokeQuery'

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
'@ | New-TestMigration -Name 'SecondTable'

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
'@ | New-TestMigration -Name 'CreateObjectsFromFiles'

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
'@ | New-TestMigration -Name 'CreateObjectInCustomDirectory'

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

        $script:testStartedAt = Invoke-RivetTestQuery -Query 'select getutcdate()' -AsScalar
    }

    AfterEach {
        try
        {
            Clear-TestDatabase -Name $RTDatabase2Name
        }
        finally
        {
            Stop-RivetTest
        }
    }

    It 'should push migrations' {
        Invoke-RTRivet -Push

        $migrationScripts = Get-MigrationScript

        $migrationScripts | ForEach-Object {

            $id,$name = $_.BaseName -split '_'

            Assert-Migration -ID $id -Name $name
        }

        (Test-Table -Name 'InvokeQuery') | Should -BeTrue
        (Test-Table -Name 'SecondTable') | Should -BeTrue
        (Test-DatabaseObject -StoredProcedure 'RivetTestSproc') | Should -BeTrue
        (Test-DatabaseObject -ScalarFunction 'RivetTestFunction') | Should -BeTrue
        (Test-DatabaseObject -View 'Migrators') | Should -BeTrue
        (Test-DatabaseObject -ScalarFunction 'MiscellaneousObject') | Should -BeTrue
        (Test-DatabaseObject -ScalarFunction 'ObjectMadeWithRelativePath') | Should -BeTrue

        # Make sure they are run in order.
        $rows = Get-MigrationInfo
        $rows | Should -Not -BeNullOrEmpty
        $rows[0].Name | Should -Be 'InvokeQuery'
        $rows[1].Name | Should -Be 'SecondTable'
        $rows[2].Name | Should -Be 'CreateObjectsFromFiles'

        $createdBefore = Get-SqlServerUtcDate
        Invoke-RTRivet -Push

        $rows = Get-MigrationInfo
        $rows | Should -Not -BeNullOrEmpty
        $rows.Count | Should -Be $migrationScripts.Count
        { Assert-True ($_.AtUtc.AddMilliseconds(-500) -lt $createdBefore) } | Should -BeTrue
    }

    It 'should push migration and add to activity table' {
        Invoke-RTRivet -Push

        $migrationScripts = Get-MigrationScript

        $migrationScripts | ForEach-Object {

            $id,$name = $_.BaseName -split '_'

            Assert-Migration -ID $id -Name $name
        }

        (Test-Table -Schema 'rivet' -Name 'Migrations') | Should -BeTrue
        (Test-Table -Schema 'rivet' -Name 'Activity') | Should -BeTrue

        $rowsmigration = Get-MigrationInfo
        $rowsactivity = Get-ActivityInfo

        $rowsmigration | Should -Not -BeNullOrEmpty
        $rowsmigration[-4].Name | Should -Be 'InvokeQuery'
        $rowsmigration[-3].Name | Should -Be 'SecondTable'
        $rowsmigration[-2].Name | Should -Be 'CreateObjectsFromFiles'
        $rowsmigration[-1].Name | Should -Be 'CreateObjectInCustomDirectory'

        $rowsactivity | Should -Not -BeNullOrEmpty
        $rowsactivity[-4].Operation | Should -Be 'Push'
        $rowsactivity[-4].Name | Should -Be 'InvokeQuery'

        $rowsactivity[-3].Operation | Should -Be 'Push'
        $rowsactivity[-3].Name | Should -Be 'SecondTable'

        $rowsactivity[-2].Operation | Should -Be 'Push'
        $rowsactivity[-2].Name | Should -Be 'CreateObjectsFromFiles'

        $rowsactivity[-1].Operation | Should -Be 'Push'
        $rowsactivity[-1].Name | Should -Be 'CreateObjectInCustomDirectory'
    }

    It 'should push migrations for multiple d bs' {
        $rivetJson = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
        if( -not ($rivetJson | Get-Member -Name 'Databases') )
        {
            $rivetJson | Add-Member -MemberType NoteProperty -Name 'Databases' -Value @()
        }
        $rivetJson.Databases = @( $RTDatabaseName, $RTDatabase2Name )
        $rivetJson | ConvertTo-Json -Depth 100 | Set-Content -Path $RTConfigFilePath

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
        $migration | New-TestMigration -Name 'ShouldPushMigrationsForMultipleDBs' | Format-Table | Out-String | Write-Verbose
        $migration | New-TestMigration -Name 'ShouldPushMigrationsForMultipleDBs' -DatabaseName $RTDatabase2Name | Format-Table | Out-String | Write-Verbose

        Invoke-RTRivet -Push -Database $RTDatabaseName,$RTDatabase2Name -ConfigFilePath $RTConfigFilePath  | Format-Table | Out-String | Write-Verbose

        Assert-Migration
        Assert-Migration -DatabaseName $RTDatabase2Name
    }

    It 'should push specific migration by name' {
        Get-MigrationScript |
            Select-Object -First 1 |
            ForEach-Object {
                $id,$name = $_.BaseName -split '_'

                Invoke-RTRivet -Push $Name

                Assert-Migration -ID $id -Name $name
            }

        $count = Measure-Migration
        $count | Should -Be 1
    }

    It 'should push specific migration with wildcard' {
        Invoke-RTRivet -Push 'Invoke*'

        $migration = Get-MigrationScript | Where-Object { $_.Name -like '*_Invoke*.ps1' }
        $id,$name = $migration.BaseName -split '_'
        Assert-Migration -ID $id -Name $name

        $count = Measure-Migration
        $count | Should -Be 1
    }

    It 'should not reapply a specific migration' {
        Get-MigrationScript |
            Select-Object -First 1 |
            ForEach-Object {
                $id,$name = $_.BaseName -split '_'

                Invoke-RTRivet -Push $name

                Assert-Migration -ID $id -Name $name

                $createdBefore = Get-SqlServerUtcDate

                Invoke-RTRivet -Push $name

                $row = Assert-Migration -ID $id -Name $name -PassThru
                ($row.AtUtc.AddMilliseconds(-500) -lt $createdBefore) | Should -BeTrue
            }

        $count = Measure-Migration
        $count | Should -Be 1

    }

    It 'should stop pushing migrations if one gives an error' {
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
'@ | New-TestMigration -Name 'AddTableWithNOColumns'

        Invoke-RTRivet -Push -ErrorAction SilentlyContinue -ErrorVariable rivetError
        ($rivetError.Count -gt 0) | Should -BeTrue

        ('TableWithoutColumnsWithColumn','TableWithoutColumns','FourthTable') | ForEach-Object {
            (Test-Table -Name $_) | Should -BeFalse
        }

        $query = 'select count(*) from InvokeQuery'
        $rowCount = Invoke-RivetTestQuery -Query $query -AsScalar
        $rowCount | Should -Be 0

        ('TableWithoutColumns','FourthTable') | ForEach-Object {
            $migration = Get-MigrationInfo -Name $_
            $migration | Should -BeNullOrEmpty
        }
    }

    It 'should fail if migration name does not exist' {
        Invoke-RTRivet -Push 'AMigrationWhichDoesNotExist' -ErrorAction SilentlyContinue
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'not found'
    }
}
