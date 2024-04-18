
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
    Remove-Item -Path 'alias:GivenMigration'
    Remove-Item -Path 'alias:ThenTable'

    $script:testDirPath = $null
    $script:testNum = 0
    $script:rivetJsonPath = $null
    $script:dbName = 'Update-Database'

    function GivenMigration
    {
        param(
            [Parameter(Mandatory, Position=0)]
            [String] $Named,

            [Parameter(Mandatory, Position=1)]
            [String] $WithContent
        )

        $WithContent | New-TestMigration -Name $Named -ConfigFilePath $script:rivetJsonPath -DatabaseName $script:dbName
    }
    function ThenTable
    {
        param(
            [Parameter(Mandatory, Position=0)]
            [String] $Named,

            [Parameter(Mandatory)]
            [switch] $Exists
        )

        Test-Table -Name $Named -DatabaseName $script:dbName | Should -BeTrue
    }


    function WhenPushing
    {
        Invoke-Rivet -Push -ConfigFilePath $script:rivetJsonPath
    }
}

Describe 'Update-Database' {
    BeforeAll {
        Remove-RivetTestDatabase -Name $script:dbName
    }

    BeforeEach {
        $script:testDirPath = Join-Path -Path $TestDrive -ChildPath ($script:testNum++)
        New-Item -Path $script:testDirPath -ItemType Directory
        $script:rivetJsonPath = GivenRivetJsonFile -In $script:testDirPath -Database $script:dbName -PassThru
        $Global:Error.Clear()
    }

    AfterEach {
        Invoke-Rivet -Pop -All -Force -ConfigFilePath $script:rivetJsonPath
    }

    It 'allows long migration names' {
        $dbMigrationsDirPath = $script:rivetJsonPath | Split-Path
        $dbMigrationsDirPath = Join-Path -Path $dbMigrationsDirPath -ChildPath 'Databases'
        $dbMigrationsDirPath = Join-Path -Path $dbMigrationsDirPath -ChildPath $script:dbName
        $dbMigrationsDirPath = Join-Path -Path $dbMigrationsDirPath -ChildPath 'Migrations'
        $migrationPathLength = $dbMigrationsDirPath.Length
        # remove length of the separator, timestamp, underscore and extension
        $name = 'a' * (259 - $migrationPathLength - 1 - 14 - 1 - 4)

        GivenMigration $name @'
            function Push-Migration
            {
                Add-Table Foobar {
                    BigInt ID
                }
            }

            function Pop-Migration
            {
                Remove-Table 'Foobar'
            }
'@

        WhenPushing
        ThenError -IsEmpty
        ThenTable 'Foobar' -Exists
    }

    It 'does not parse already applied migrations' {
        $migrationContent = @'
            function Push-Migration
            {
                Add-Schema 'test'
            }

            function Pop-Migration
            {
                Remove-Schema 'test'
            }
'@
        $migration = GivenMigration -Named 'WillBeUnparsable' $migrationContent
        WhenPushing
        '{' | Set-Content -Path $migration.FullName
        try
        {
            WhenPushing
            ThenError -IsEmpty
        }
        finally
        {
            $migrationContent | Set-Content -Path $migration.FullName
        }
    }
}