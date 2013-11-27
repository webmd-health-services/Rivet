
$convertRivetMigration = Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Extras\Convert-Migration.ps1' -Resolve
$outputDir = $null
$testedOperations = @{ }

function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'ConvertMigration' 
    Start-RivetTest

    & (Join-Path -Path $PSScriptRoot -ChildPath '..\Tools\SqlPS\Import-SqlPS.ps1' -Resolve)

    $outputDir = New-TempDir -Prefix 'Test-ConvertMigration'
}

function Stop-Test
{
    Get-Migration -ConfigFilePath $RTConfigFilePath |
        Select-Object -ExpandProperty PushOperations |
        ForEach-Object { $testedOperations[$_.GetType()] = $true }

    Remove-Item -Path $outputDir -Recurse
    Stop-RivetTest
}
 
function Stop-TestFixture
{
    $missingOps = [Reflection.Assembly]::GetAssembly( [Rivet.Operations.Operation] ) |
                    ForEach-Object { $_.GetTypes() } | 
                    Where-Object { $_.IsClass } |
                    Where-Object { $_.Namespace -eq 'Rivet.Operations' } |
                    Where-Object { -not $_.IsAbstract } |
                    Where-Object { -not $testedOperations.ContainsKey( $_ ) } |
                    Select-Object -ExpandProperty 'Name' |
                    Sort-Object

    #Assert-Null $missingOps ("The following operations weren't tested:`n * {0}" -f ($missingOps -join "`n * "))
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
    Assert-StoredProcedure -SchemaName 's' -Name 'prcT'
}

function Test-ShouldCreateIdempotentQueryForAddOperations
{
    @'
function Push-Migration
{
    Add-Schema 'idempotent'
    
    $idempotent = @{ SchemaName = 'idempotent' }
    $crops = @{ TableName = 'Crops' }
    $farmers = @{ TableName = 'Farmers' }

    Add-Table @idempotent $farmers.TableName {
        int 'ID' -NotNull
        varchar 'Name' -NotNull -Size 500
    }
    Add-PrimaryKey @idempotent @farmers -ColumnName 'ID'
    Add-Row @idempotent @farmers -Column @{ 'ID' = 1; 'Name' = 'Blackbird' }

    Update-Table @idempotent $farmers.TableName -UpdateColumn {
        varchar 'Name' -NotNull -Size 50
    } 

    Update-Table @idempotent $farmers.TableName -AddColumn {
        varchar 'Zip' -Size 10
    }
    Rename-Column @idempotent @farmers -Name 'Zip' -NewName 'ZipCode'

    Add-Table @idempotent $crops.TableName {
        int 'ID' -Identity
        varchar 'Name' -Size 50
        int 'FarmerID' -NotNull
    }
    Add-CheckConstraint @idempotent @crops -Name 'CK_Farmers_AllowedCrops' -Expression 'Name = ''Strawberries'' or Name = ''Rasberries'''
    Rename-Object @idempotent -Name 'CK_Farmers_AllowedCrops' -NewName 'CK_Crops_AllowedCrops'
    Add-DefaultConstraint @idempotent @crops -ColumnName 'Name' -Expression '''StrawBerries'''
    Add-Description @idempotent @crops -ColumnName 'Name' 'Yumm!'
    Update-Description @idempotent @crops -ColumnName 'Name' 'Yummy!'
    Add-ForeignKey @idempotent @crops -ColumnName 'FarmerID' `
                   -ReferencesSchema $idempotent.SchemaName -References $farmers.TableName -ReferencedColumn 'ID'
    Add-Index @idempotent @crops -ColumnName 'Name'
    Rename-Index @idempotent @crops 'IX_idempotent_Crops_Name' 'IX_Crops_Name2'
    Add-UniqueKey @idempotent @crops 'Name'


    Add-DataType @idempotent -Name 'GUID' -From 'uniqueidentifier'

    Add-StoredProcedure 'GetFarmers' @idempotent -Definition 'AS select * from Crops'
    Update-StoredProcedure 'GetFarmers' @idempotent -Definition 'AS select * from Farmers'

    Add-Synonym -Name 'Crop' @idempotent -TargetSchemaName $idempotent.SchemaName 'Crops'

    Add-Trigger 'CropActivity' @idempotent -Definition "on idempotent.Crops after insert as return"
    Update-Trigger 'CropActivity' @idempotent -Definition "on idempotent.Crops after insert, update as return"

    Add-UserDefinedFunction 'GetInteger' @idempotent -Definition '(@Number int) returns int as begin return @Number end'
    Update-UserDefinedFunction 'GetInteger' @idempotent -Definition '(@Number int) returns int as begin return @Number + @Number end'

    Add-View 'FarmerCrops' @idempotent -Definition "as select Farmers.Name CropName, Crops.Name FarmersName from Crops join Farmers on Crops.FarmerID = Farmers.ID"
    Update-View 'FarmerCrops' @idempotent -Definition "as select Farmers.Name FarmerName, Crops.Name CropName from Crops join Farmers on Crops.FarmerID = Farmers.ID"
}

function Pop-Migration
{
    $idempotent = @{ SchemaName = 'idempotent' }
    $crops = @{ TableName = 'Crops' }
    $farmers = @{ TableName = 'Farmers' }

    Remove-View 'FarmerCrops' @idempotent
    Remove-UserDefinedFunction @idempotent 'GetInteger'
    Remove-Synonym @idempotent 'Crop'
    Remove-StoredProcedure @idempotent 'GetFarmers'
    Remove-DataType @idempotent 'GUID'
    Remove-Table @idempotent $crops.TableName
    Remove-Table @idempotent $farmers.TableName
}
'@ | New-Migration -Name 'AddOperations'

    & $convertRivetMigration -ConfigFilePath $RTConfigFilePath -OutputPath $outputDir

    Assert-FileExists (Join-Path -Path $outputDir -ChildPath ('{0}.Schema.sql' -f $RTDatabaseName))
    Assert-FileExists (Join-Path -Path $outputDir -ChildPath ('{0}.CodeObject.sql' -f $RTDatabaseName))
    Assert-FileExists (Join-Path -Path $outputDir -ChildPath ('{0}.Data.sql' -f $RTDatabaseName))

    Invoke-ConvertedScripts


    $schema = @{ SchemaName = 'idempotent' }
    $crops = @{ TableName = 'Crops' }
    $farmers = @{ TableName = 'Farmers' }

    Assert-Schema -Name $schema.SchemaName
    Assert-Table @schema $farmers.TableName
    Assert-Column @schema @farmers -Name 'Name' -DataType 'varchar' -NotNull -Size 50
    Assert-Column @schema @farmers -Name 'ZipCode' -DataType 'varchar' -Size 10
    Assert-PrimaryKey @schema @farmers -ColumnName 'ID'
    Assert-NotNull (Invoke-RivetTestQuery -Query ('select * from {0}.{1} where ID = 1 and Name = ''Blackbird''' -f $schema.SchemaName,$farmers.TableName))
    
    Assert-Table @schema -Name $crops.TableName -Descriptoin 'Yummy!'
    Assert-CheckConstraint -Name 'CK_Crops_AllowedCrops' -Definition '([Name]=''Strawberries'' or [Name]=''Rasberries'')'
    Assert-DefaultConstraint @schema @crops -ColumnName 'Name' -Definition '(''Strawberries'')'
    Assert-ForeignKey @schema @crops -ReferencesSchema $schema.SchemaName -References $farmers.TableName
    Assert-Index @schema @crops -Name 'IX_Crops_Name2' -ColumnName 'Name'
    Assert-UniqueKey @schema @crops -ColumnName 'Name'
    Assert-DataType @schema -Name 'GUID' -BaseTypeName 'uniqueidentifier' -UserDefined
    Assert-StoredProcedure @schema -Name 'GetFarmers' -Definition 'AS select * from Farmers'
    Assert-Synonym @schema -Name 'Crop' -TargetObjectName '[idempotent].[Crops]'
    Assert-Trigger @schema -Name 'CropActivity' -Definition 'on idempotent.Crops after insert, update as return'
    Assert-UserDefinedFunction @schema -Name 'GetInteger' -Definition '(@Number int) returns int as begin return @Number + @Number end'
    Assert-View @schema -Name 'FarmerCrops' -Definition "as select Farmers.Name FarmerName, Crops.Name CropName from Crops join Farmers on Crops.FarmerID = Farmers.ID"
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