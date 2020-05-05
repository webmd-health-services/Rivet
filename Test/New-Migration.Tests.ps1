
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

$dbsRoot = $null
$rivetPath = Join-Path $PSScriptRoot -ChildPath '..\Rivet\rivet.ps1' -Resolve

Describe 'New-Migration' {
    BeforeEach {
        Start-RivetTest -IgnoredDatabase 'ignored'
        $Global:LASTEXITCODE = 0
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should create one migration' {
        & $rivetPath -New -Name 'ShouldCreateOneMigration' -Database $RTDatabaseName -ConfigFilePath $RTConfigFilePath
        $? | Should -BeTrue
        $LASTEXITCODE | Should -Be 0
        
        $rivetTestRoot = Join-Path $RTDatabasesRoot $RTDatabaseName
        $rivetTestRoot | Should -Exist
        $migrationRoot = Join-Path $rivetTestRoot Migrations
        $migrationRoot | Should -Exist
        
        $id = (Get-Date).ToString('yyyyMMddHHmm')
        $migrationPath = Join-Path $rivetTestRoot "Migrations\$($id)??_ShouldCreateOneMigration.ps1"
        (Test-Path -Path $migrationPath -PathType Leaf) | Should -BeTrue
        $migration = Get-Item -Path $migrationPath
        $migration | Should -Not -BeNullOrEmpty
        ($migration -is [IO.FileInfo]) | Should -BeTrue
    
        $otherMigrations = Get-ChildItem (Join-Path -Path $RTDatabasesRoot -ChildPath *\Migrations\*.ps1) |
                                Where-Object { $_.FullName -notlike "*\$RTDatabaseName\Migrations\*" }
        $otherMigrations | Should -BeNullOrEmpty
    }
    
    It 'should create multiple migrations' {
        $id = (Get-Date).ToString('yyyyMMddHHmm')
    
        & $rivetPath -New -Name 'ShouldCreateMultipleMigrations' -Database $RTDatabaseName,RivetTestTwo -ConfigFilePath $RTConfigFilePath
        $? | Should -BeTrue
        $LASTEXITCODE | Should -Be 0
        
        ($RTDatabaseName,'RivetTestTwo') | ForEach-Object {
            
            $dbRoot = Join-Path $RTDatabasesRoot $_
            $dbRoot | Should -Exist
            $migrationRoot = Join-Path $dbRoot Migrations
            $migrationRoot | Should -Exist
            
            $migrationPath = Join-Path $dbRoot "Migrations\$($id)??_ShouldCreateMultipleMigrations.ps1"
            (Test-Path -Path $migrationPath -PathType Leaf) | Should -BeTrue
            $migration = Get-Item -Path $migrationPath
            $migration | Should -Not -BeNullOrEmpty
            ($migration -is [IO.FileInfo]) | Should -BeTrue
        }
    
        $otherMigrations = Get-ChildItem (Join-Path -Path $RTDatabasesRoot -ChildPath *\Migrations\*.ps1) |
                            Where-Object { $_.FullName -notlike "*\$RTDatabaseName\Migrations\*" } |
                            Where-Object { $_.FullName -notlike "*\RivetTestTwo\Migrations\*" }
        $otherMigrations | Should -BeNullOrEmpty
    }
    
    It 'should create migration in all databases' {
        $migrations = Get-ChildItem (Join-Path -Path $RTDatabasesRoot -ChildPath *\Migrations\*.ps1)
        $migrations | Should -BeNullOrEmpty
    
        & $rivetPath -New -Name 'ShouldCreateMigrationAcrossAllDatabases' -ConfigFilePath $RTConfigFilePath
        
        Get-ChildItem -Path $RTDatabasesRoot |
            Where-Object { $_.PsIsContainer } |
            ForEach-Object {
                $migrationDirPath = Join-Path -Path $_.FullName -ChildPath Migrations
                $migration = Get-ChildItem -Path $migrationDirPath -Filter *_ShouldCreateMigrationAcrossAllDatabases.ps1
                $migration | Should -Not -BeNullOrEmpty
            }
    }
    
    It 'should require database name if new database' {
        # Remove database directories.
        Get-ChildItem -Path $RTDatabasesRoot | 
            Where-Object { $_.PsIsContainer } |
            Remove-Item -Recurse
    
        & $rivetPath -New -Name 'ShouldCreateMigrationAcrossAllDatabases' -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
        $LASTEXITCODE | Should -Be 1
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'explicit database name'
    }
    
    It 'should create database directory if it does not exist' {
        & $rivetPath -New -Name 'ShouldCreateMigrationForNewDatabase' -Database 'NewDatabase' -ConfigFilePath $RTConfigFilePath
        $LASTEXITCODE | Should -Be 0
        (Join-Path $RTDatabasesRoot 'NewDatabase\Migrations\*_ShouldCreateMigrationForNewDatabase.ps1') | Should -Exist
        $otherMigrations = Get-ChildItem (Join-Path -Path $RTDatabasesRoot -ChildPath *\Migrations\*.ps1) |
                            Where-Object { $_.FullName -notlike "*\NewDatabase\Migrations\*" }
        $otherMigrations | Should -BeNullOrEmpty
    }
    
    It 'should create migrations with unique ids' {
        $m1 = & $rivetPath -New -Name 'First' -ConfigFilePath $RTConfigFilePath
        $m2 = & $rivetPath -New -Name 'Second' -ConfigFilePath $RTConfigFilePath
    
        ($m1.BaseName -match '^(\d+)') | Should -BeTrue
        $id1 = $Matches[1]
    
        ($m2.BaseName -match '^(\d+)') | Should -BeTrue
        $id2 = $Matches[1]
    
        $id2 | Should -Not -Be $id1
    
    }
    
    It 'should reject migrations with names that are too long' {
        $name = 'a' * 242
    
        try
        {
            & $rivetPath -New -Name $name -ConfigFilePath $RTConfigFilePath
            Fail 'Didn''t throw an exception with a name that''s too long.'
        }
        catch
        {
            $ex = $_.Exception
            $ex.GetType().FullName | Should -Be 'System.Management.Automation.ParameterBindingValidationException'
            $ex.Message | Should -Match 'parameter ''Name'''
            $ex.Message | Should -Match 'is too long'
        }
    }
    
    It 'should handle new migration for ignored database' {
        & $rivetPath -New -Name 'Migration' -Database 'Ignored' -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
        $Global:Error.Count | Should -BeGreaterThan 0
    }
    
}
