
$dbsRoot = $null
$rivetPath = Join-Path $TestDir ..\Rivet\rivet.ps1 -Resolve

function Start-Test
{
    & (Join-Path -Path $TestDir -ChildPath RivetTest\Import-RivetTest.ps1 -Resolve) -DatabaseName 'RivetTest'
    Start-RivetTest

    Get-ChildItem -Path (Join-Path -Path $RTDatabasesRoot *\Migrations\*.ps1) |
        Remove-Item
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateOneMigration
{
    & $rivetPath -New -Name 'ShouldCreateOneMigration' -Database $RTDatabaseName -ConfigFilePath $RTConfigFilePath
    Assert-True $?
    Assert-LastProcessSucceeded
    
    $rivetTestRoot = Join-Path $RTDatabasesRoot $RTDatabaseName
    Assert-DirectoryExists $rivetTestRoot
    $migrationRoot = Join-Path $rivetTestRoot Migrations
    Assert-DirectoryExists $migrationRoot
    
    $id = (Get-Date).ToString('yyyyMMddHHmm')
    $migrationPath = Join-Path $rivetTestRoot "Migrations\$($id)??_ShouldCreateOneMigration.ps1"
    Assert-True (Test-Path -Path $migrationPath -PathType Leaf)
    $migration = Get-Item -Path $migrationPath
    Assert-NotNull $migration
    Assert-True ($migration -is [IO.FileInfo])

    $otherMigrations = Get-ChildItem (Join-Path -Path $RTDatabasesRoot -ChildPath *\Migrations\*.ps1) |
                            Where-Object { $_.FullName -notlike "*\$RTDatabaseName\Migrations\*" }
    Assert-Null $otherMigrations
}

function Test-ShouldCreateMultipleMigrations
{
    $id = (Get-Date).ToString('yyyyMMddHHmm')

    & $rivetPath -New -Name 'ShouldCreateMultipleMigrations' -Database $RTDatabaseName,RivetTestTwo -ConfigFilePath $RTConfigFilePath
    Assert-True $?
    Assert-LastProcessSucceeded
    
    ($RTDatabaseName,'RivetTestTwo') | ForEach-Object {
        
        $dbRoot = Join-Path $RTDatabasesRoot $_
        Assert-DirectoryExists $dbRoot
        $migrationRoot = Join-Path $dbRoot Migrations
        Assert-DirectoryExists $migrationRoot
        
        $migrationPath = Join-Path $dbRoot "Migrations\$($id)??_ShouldCreateMultipleMigrations.ps1"
        Assert-True (Test-Path -Path $migrationPath -PathType Leaf)
        $migration = Get-Item -Path $migrationPath
        Assert-NotNull $migration
        Assert-True ($migration -is [IO.FileInfo])
    }

    $otherMigrations = Get-ChildItem (Join-Path -Path $RTDatabasesRoot -ChildPath *\Migrations\*.ps1) |
                        Where-Object { $_.FullName -notlike "*\$RTDatabaseName\Migrations\*" } |
                        Where-Object { $_.FullName -notlike "*\RivetTestTwo\Migrations\*" }
    Assert-Null $otherMigrations
}

function Test-ShouldCreateMigrationInAllDatabases
{
    $migrations = Get-ChildItem (Join-Path -Path $RTDatabasesRoot -ChildPath *\Migrations\*.ps1)
    Assert-Null $migrations

    & $rivetPath -New -Name 'ShouldCreateMigrationAcrossAllDatabases' -ConfigFilePath $RTConfigFilePath
    
    Get-ChildItem -Path $RTDatabasesRoot |
        Where-Object { $_.PsIsContainer } |
        ForEach-Object {
            $migrationDirPath = Join-Path -Path $_.FullName -ChildPath Migrations
            $migration = Get-ChildItem -Path $migrationDirPath -Filter *_ShouldCreateMigrationAcrossAllDatabases.ps1
            Assert-NotNull $migration
        }
}

function Test-ShouldRequireDatabaseNameIfNewDatabase
{
    # Remove database directories.
    Get-ChildItem -Path $RTDatabasesRoot | 
        Where-Object { $_.PsIsContainer } |
        Remove-Item -Recurse

    & $rivetPath -New -Name 'ShouldCreateMigrationAcrossAllDatabases' -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
    Assert-LastProcessFailed
    Assert-Error -Last 'explicit database name'
}

function Test-ShouldCreateDatabaseDirectoryIfItDoesNotExist
{
    & $rivetPath -New -Name 'ShouldCreateMigrationForNewDatabase' -Database 'NewDatabase' -ConfigFilePath $RTConfigFilePath
    Assert-LastProcessSucceeded
    Assert-FileExists (Join-Path $RTDatabasesRoot 'NewDatabase\Migrations\*_ShouldCreateMigrationForNewDatabase.ps1')
    $otherMigrations = Get-ChildItem (Join-Path -Path $RTDatabasesRoot -ChildPath *\Migrations\*.ps1) |
                        Where-Object { $_.FullName -notlike "*\NewDatabase\Migrations\*" }
    Assert-Null $otherMigrations
}

function Test-ShouldCreateMigrationsWithUniqueIDs
{
    $m1 = ' ' | New-Migration -Name 'First'
    $m2 = ' ' | New-Migration -Name 'Second'

    Assert-True ($m1.BaseName -match '^(\d+)')
    $id1 = $Matches[1]

    Assert-True ($m2.BaseName -match '^(\d+)')
    $id2 = $Matches[1]

    Assert-NotEqual $id1 $id2

}