
$convertRivetMigration = Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Extras\Convert-Migration.ps1' -Resolve
$outputDir = $null
$dbRootDir = $null
$rivetJsonPath = $null
$sqlServer = $null
$dbName = $null

function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'ConvertMigration' 
    Start-RivetTest

    & (Join-Path -Path $PSScriptRoot -ChildPath '..\Tools\SqlPS\Import-SqlPS.ps1' -Resolve)

    $outputDir = New-TempDir -Prefix 'Test-ConvertMigration'
}

function Stop-Test
{
    Remove-Item -Path $outputDir -Recurse
    Stop-RivetTest
}

function Test-ShouldCreateOutputPath
{
    $Error.Clear()
    $outputPath = Join-Path -Path $env:TEMP -ChildPath ([IO.Path]::GetRandomFileName())
    Assert-DirectoryDoesNotExist $outputPath
    & $convertRivetMigration -OutputPath $outputPath -ConfigFilePath $RTConfigFilePath
    Assert-Equal 0 $Error.Count
    Assert-DirectoryExists $outputPath
}

function Test-ShouldCreateScriptsForDatabase
{
    $null = New-TempDirectoryTree -Path $RTDatabasesRoot -Tree @'
+ Common
  + Migrations
    * 00000000000001_A.ps1
    * 00000000000002_B.ps1
+ Wellmed
  + Migrations
    * 00000000000001_A.ps1
'@

@'
function Push-Migration
{
    Add-Table 'T' -Description 'Umm, a table.' {
        int ID -Identity -Description 'Umm, a column.'
        varchar C -Size 50 -NotNull -Description 'Umm, another column.'
    }

    Add-View 'vwT' -Definition 'as select * from T'

    Add-Row 'T' -Column @{ C = 'Meh' }
}

function Pop-Migration 
{
}
'@ | Set-Content -Path (Join-Path -Path $RTDatabasesRoot -ChildPath 'Common\Migrations\00000000000001_A.ps1')

@'
function Push-Migration
{
    Add-ExtendedProperty 'MS_Description' 'Umm, a view.' -ViewName 'vwT'
}

function Pop-Migration
{
}
'@ | Set-Content -Path (Join-Path -Path $RTDatabasesRoot -ChildPath 'Common\Migrations\00000000000002_B.ps1')

@'
function Push-Migration
{
    Add-Schema 's'

    Add-StoredProcedure -SchemaName s 'prcT' -Definition 'as select 1'
}

function Pop-Migration
{
}
'@ | Set-Content -Path (Join-Path -Path $RTDatabasesRoot -ChildPath 'Wellmed\Migrations\00000000000001_A.ps1')

    & $convertRivetMigration -ConfigFilePath $RTConfigFilePath -OutputPath $outputDir

    Assert-FileExists (Join-Path -Path $outputDir -ChildPath 'Common.Schema.sql')
    Assert-FileExists (Join-Path -Path $outputDir -ChildPath 'Common.CodeObject.sql')
    Assert-FileExists (Join-Path -Path $outputDir -ChildPath 'Common.Data.sql')
    Assert-FileExists (Join-Path -Path $outputDir -ChildPath 'Wellmed.Schema.sql')
    Assert-FileExists (Join-Path -Path $outputDir -ChildPath 'Wellmed.CodeObject.sql')

    Invoke-ConvertedScripts

    Assert-Table -Name 'T' -Description 'Umm, a table.'
    Assert-Column -TableName 'T' -Name 'ID' -DataType 'int' -NotNull -Increment 1 -Seed 1 -Description 'Umm, a column.'
    Assert-Column -TableName 'T' -Name 'C' -DataType 'varchar' -NotNull -Size 50 -Description 'Umm, another column.'
    Assert-View -Name 'vwT' -Description 'Umm, a view.'
    Assert-NotNull (Invoke-RivetTestQuery -Query 'select ID, C from [T]')
    Assert-NotNull (Invoke-RivetTestQuery -Query 'select * from sys.schemas where name = ''s''')
    Assert-StoredProcedure -Name 'prcT'
}

function Invoke-ConvertedScripts
{
    $ranConvertedScripts = $false
    Invoke-Command {
            Get-ChildItem -Path $outputDir -Filter '*.Schema.sql'
            Get-ChildItem -Path $outputDir -Filter '*.CodeObject.sql'
            Get-ChildItem -Path $outputDir -Filter '*.Data.sql'
        } |
        ForEach-Object {
            $ranConvertedScripts = $true
            $file = $_
            try
            {
                # Run 'em twice.  Make sure they really *are* idempotent.
                $result = Invoke-Sqlcmd -ServerInstance $RTServer -Database $RTDatabaseName -InputFile $_.FullName
                $result | Format-Table -AutoSize

                $result = Invoke-Sqlcmd -ServerInstance $RTServer -Database $RTDatabaseName -InputFile $_.FullName
                $result | Format-Table -AutoSize

                Assert-LastProcessSucceeded
            }
            catch
            {
                Fail ('{0} failed to execute: {1}' -f $file.Name,$_.Exception.Message)
            }
        }
    Assert-True $ranConvertedScripts
}