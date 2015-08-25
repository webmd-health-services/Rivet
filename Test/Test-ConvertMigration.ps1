
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
$rivetPath = Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\rivet.ps1' -Resolve
$convertRivetMigration = Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Extras\Convert-Migration.ps1' -Resolve
$outputDir = $null
$testedOperations = @{ }
$pluginsPath = $null
$testsRun = 0

function Start-Test
{
    $pluginsPath = New-TempDir -Prefix $PSCommandPath
    Start-RivetTest -PluginPath $pluginsPath

    & (Join-Path -Path $PSScriptRoot -ChildPath '..\Tools\SqlPS\Import-SqlPS.ps1' -Resolve)

    $outputDir = New-TempDir -Prefix 'Test-ConvertMigration'
    ++$testsRun

    Invoke-RTRivet -Push
}

function Stop-Test
{
    Get-Migration -ConfigFilePath $RTConfigFilePath |
        Select-Object -ExpandProperty PushOperations |
        ForEach-Object { $testedOperations[$_.GetType()] = $true }

    Remove-Item -Path $outputDir -Recurse
    Get-ChildItem -Path $RTDatabaseMigrationRoot -Filter '*.off' |
        Rename-Item -NewName { $_.BaseName }
    Stop-RivetTest
    Remove-Item $pluginsPath -Recurse
}
 
function Stop-TestFixture
{
    $missingOps = [Reflection.Assembly]::GetAssembly( [Rivet.Operation] ) |
                    ForEach-Object { $_.GetTypes() } | 
                    Where-Object { $_.IsClass } |
                    Where-Object { $_.Namespace -eq 'Rivet.Operations' } |
                    Where-Object { -not $_.IsAbstract } |
                    Where-Object { -not $testedOperations.ContainsKey( $_ ) } |
                    Select-Object -ExpandProperty 'Name' |
                    Sort-Object

    if( $testsRun -gt 1 )
    {
        Assert-Null $missingOps ("The following operations weren't tested:`n * {0}" -f ($missingOps -join "`n * "))
    }
}

function Test-ShouldCreateOutputPath
{
    $outputPath = Join-Path -Path $env:TEMP -ChildPath ([IO.Path]::GetRandomFileName())
    Assert-DirectoryDoesNotExist $outputPath
    & $convertRivetMigration -OutputPath $outputPath -ConfigFilePath $RTConfigFilePath
    Assert-NoError
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
    Remove-View 'vwT'
    Remove-Table 'T'
}
'@ | Set-Content -Path (Join-Path -Path $RTDatabasesRoot -ChildPath 'Common\Migrations\00000000000001_A.ps1')

@'
function Push-Migration
{
    Add-ExtendedProperty 'MS_Description' 'Umm, a view.' -ViewName 'vwT'
}

function Pop-Migration
{
    Remove-ExtendedProperty 'MS_Description' -ViewName 'vwT'
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
    Remove-StoredProcedure -SchemaName 's' 'prcT'
    Remove-Schema 's'
}
'@ | Set-Content -Path (Join-Path -Path $RTDatabasesRoot -ChildPath 'Wellmed\Migrations\00000000000001_A.ps1')

    Assert-ConvertMigration -DatabaseName 'Common' -Schema -CodeObject -Data -ExtendedProperty
    Assert-NoError
    Assert-ConvertMigration -DatabaseName 'Wellmed' -Schemas -CodeObject
    Assert-NoError

    try
    {
        Assert-Table -Name 'T' -Description 'Umm, a table.'
        Assert-Column -TableName 'T' -Name 'ID' -DataType 'int' -NotNull -Increment 1 -Seed 1 -Description 'Umm, a column.'
        Assert-Column -TableName 'T' -Name 'C' -DataType 'varchar' -NotNull -Size 50 -Description 'Umm, another column.'
        Assert-View -Name 'vwT' -Description 'Umm, a view.'
        Assert-NotNull (Invoke-RivetTestQuery -Query 'select ID, C from [T]')
        Assert-NotNull (Invoke-RivetTestQuery -Query 'select * from sys.schemas where name = ''s''')
        Assert-StoredProcedure -SchemaName 's' -Name 'prcT'

        [string[]]$lines = Get-Content -Path (Join-Path $outputDir 'Common.ExtendedProperty.sql') | 
                           Where-Object { $_ -match 'Umm, a view' }
        Assert-Equal 1 $lines.Count 'Get-Migration isn''t clearing Push-Migration/Pop-Migration functions left from previous migrations.'
    }
    finally
    {
        Pop-ConvertedScripts -Database 'Common'
        Pop-ConvertedScripts -Database 'Wellmed'
    }         
}

function Test-ShouldCreateIdempotentQueryForAddOperations
{
    $m = @'
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

    Invoke-Ddl 'select 1'

    Update-CodeObjectMetadata @idempotent 'FarmerCrops'

    Invoke-SqlScript -Path 'query.sql'
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

    Remove-Schema 'idempotent'
}
'@ | New-Migration -Name 'ShouldCreateIdempotentQueryForAddOperations'

    $scriptPath = Split-Path -Parent -Path $m
    $scriptPath = Join-Path -Path $scriptPath -ChildPath 'query.sql'
    "if not exists (select * from sys.schemas where name = 'convertmigrationquery')`n`t exec sp_executesql N'convertmigrationquery'" | Set-Content -Path $scriptPath

    Assert-ConvertMigration -Schemas -Schema -CodeObject -Data -ExtendedProperty -Unknown -Trigger -Constraint -ForeignKey -Type

    try
    {
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
        Assert-CheckConstraint -Name 'CK_Farmers_AllowedCrops' -Definition '([Name]=''Strawberries'' or [Name]=''Rasberries'')'
        Assert-DefaultConstraint @schema @crops -ColumnName 'Name' -Definition '(''Strawberries'')'
        Assert-ForeignKey @schema @crops -ReferencesSchema $schema.SchemaName -References $farmers.TableName
        Assert-Index -Name 'IX_Crops_Name2' -ColumnName 'Name'
        Assert-UniqueKey @schema @crops -ColumnName 'Name'
        Assert-DataType @schema -Name 'GUID' -BaseTypeName 'uniqueidentifier' -UserDefined
        Assert-StoredProcedure @schema -Name 'GetFarmers' -Definition 'AS select * from Farmers'
        Assert-Synonym @schema -Name 'Crop' -TargetObjectName '[idempotent].[Crops]'
        Assert-Trigger @schema -Name 'CropActivity' -Definition 'on idempotent.Crops after insert, update as return'
        Assert-UserDefinedFunction @schema -Name 'GetInteger' -Definition '(@Number int) returns int as begin return @Number + @Number end'
        Assert-View @schema -Name 'FarmerCrops' -Definition "as select Farmers.Name FarmerName, Crops.Name CropName from Crops join Farmers on Crops.FarmerID = Farmers.ID"
        Assert-False (Test-Schema 'convertmigrationquery')

        $scriptQuery = Get-Content -Path (Join-Path $outputDir -ChildPath ('{0}.Unknown.sql' -f $RTDatabaseName)) |
                            Where-Object { $_ -match 'sp_executesql N''convertmigrationquery''' }
        Assert-NotNull $scriptQuery
    }
    finally
    {
        Pop-ConvertedScripts
    }

}

function Test-ShouldCreateIdempotentQueriesForRemoveOperations
{
    $migration = @"
function Push-Migration
{
    `$idempotent = @{ SchemaName = 'idempotent' }
    `$crops = @{ TableName = 'Crops' }
    `$farmers = @{ TableName = 'Farmers' }

    Add-Schema 'empty'
    Add-Schema `$idempotent.SchemaName
    
    Add-Table @idempotent `$farmers.TableName {
        int 'ID' -NotNull
        varchar 'Name' -NotNull -Size 500
        varchar 'ZipCode' -Size 10
    }
    Add-PrimaryKey @idempotent @farmers -ColumnName 'ID'

    Add-Table @idempotent `$crops.TableName {
        int 'ID' -Identity
        varchar 'Name' -Size 50
        int 'FarmerID' -NotNull
        varchar 'RemoveMe' -Size 5
    }
    Add-CheckConstraint @idempotent @crops -Name 'CK_Crops_AllowedCrops' -Expression 'Name = ''Strawberries'' or Name = ''Rasberries'''
    Add-DefaultConstraint @idempotent @crops -ColumnName 'Name' -Expression '''Strawberries'''
    Add-Description @idempotent @crops -ColumnName 'Name' 'Yumm!'
    Add-ForeignKey @idempotent @crops -ColumnName 'FarmerID' -ReferencesSchema `$idempotent.SchemaName -References `$farmers.TableName -ReferencedColumn 'ID'
    Add-Index @idempotent @crops -ColumnName 'Name'
    Add-UniqueKey @idempotent @crops 'Name'

    Add-DataType @idempotent -Name 'GUID' -From 'uniqueidentifier'
    Add-Synonym -Name 'Crop' @idempotent -TargetSchemaName `$idempotent.SchemaName 'Crops'

    Add-StoredProcedure 'GetFarmers' @idempotent -Definition 'AS select * from Crops'
    Add-Trigger 'CropActivity' @idempotent -Definition "on idempotent.Crops after insert as return"
    Add-UserDefinedFunction 'GetInteger' @idempotent -Definition '(@Number int) returns int as begin return @Number end'
    Add-View 'FarmerCrops' @idempotent -Definition "as select Farmers.Name CropName, Crops.Name FarmersName from Crops join Farmers on Crops.FarmerID = Farmers.ID"

    Add-Table @idempotent 'removeme' {
        int 'ID' -Identity
    }
}

function Pop-Migration
{
    `$idempotent = @{ SchemaName = 'idempotent' }
    `$crops = @{ TableName = 'Crops' }
    `$farmers = @{ TableName = 'Farmers' }

    Remove-Table @idempotent 'removeme'

    Remove-View 'FarmerCrops' @idempotent
    Remove-UserDefinedFunction 'GetInteger' @idempotent
    Remove-Trigger 'CropActivity' @idempotent
    Remove-StoredProcedure 'GetFarmers' @idempotent
    
    Remove-Synonym -Name 'Crop' @idempotent
    Remove-DataType @idempotent -Name 'GUID'
    
    Remove-UniqueKey @idempotent @crops -Name '$(New-ConstraintName -UniqueKey -SchemaName 'idempotent' 'Crops' 'Name')'
    Remove-Index @idempotent @crops -Name '$(New-ConstraintName -Index -SchemaName 'idempotent' 'Crops' 'Name')'
    Remove-ForeignKey @idempotent @crops -Name '$(New-ForeignKeyConstraintName -SourceSchema 'idempotent' 'Crops' -TargetSchema 'idempotent' 'Farmers')'
    Remove-Table @idempotent `$crops.TableName
    Remove-Table @idempotent `$farmers.TableName
    Remove-Schema 'empty'
    Remove-Schema `$idempotent.SchemaName
}
"@ | New-Migration -Name 'ShouldCreateIdempotentQueriesForRemoveOperations'

    Invoke-RTRivet -Push 'ShouldCreateIdempotentQueriesForRemoveOperations'

    Assert-Table -SchemaName 'idempotent' -Name 'removeme'
    $migration | Rename-Migration

    @"
`$schema = @{ SchemaName = 'idempotent' }
`$crops = @{ TableName = 'Crops' }
`$farmers = @{ TableName = 'Farmers' }

function Push-Migration
{
    Remove-CheckConstraint @schema @crops -Name 'CK_Crops_AllowedCrops'
    Update-Table @schema -Name `$farmers.TableName -Remove 'RemoveMe'
    Remove-DataType @schema -Name 'GUID'
    Remove-DefaultConstraint @schema @crops -Name '$(New-ConstraintName -Default -SchemaName 'idempotent' 'Crops' 'Name')'
    Remove-Description @schema @crops -ColumnName 'Name'
    Remove-ForeignKey @schema @crops -Name '$(New-ForeignKeyConstraintName -SourceSchema 'idempotent' 'Crops' -TargetSchema 'idempotent' 'Farmers')'
    Remove-Index @schema @crops -Name '$(New-ConstraintName -Index -SchemaName 'idempotent' 'Crops' 'Name')'
    Remove-PrimaryKey @schema @crops -Name '$(New-ConstraintName -PrimaryKey -SchemaName 'schema' 'Crops')'
    Remove-Row @schema @farmers -Where 'ID = 1'
    Remove-Schema 'empty'
    Remove-StoredProcedure @schema -Name 'GetFarmers'
    Remove-Synonym @schema -Name 'Crop'
    Remove-Table @schema -Name 'removeme'
    Remove-Trigger @schema -Name 'CropActivity'
    Remove-UniqueKey @schema @crops -Name '$(New-ConstraintName -UniqueKey -SchemaName 'idempotent' 'Crops' 'Name')'
    Remove-UserDefinedFunction @schema -Name 'GetInteger'
    Remove-View @schema -Name 'FarmerCrops'
}

function Pop-Migration
{
    Add-Table @schema `$farmers.TableName {
        int 'ID' -NotNull
        varchar 'Name' -NotNull -Size 500
        varchar 'ZipCode' -Size 10
    }
    Add-PrimaryKey @schema @farmers -ColumnName 'ID'

    Add-Table @schema `$crops.TableName {
        int 'ID' -Identity
        varchar 'Name' -Size 50
        int 'FarmerID' -NotNull
        varchar 'RemoveMe' -Size 5
    }
    Add-CheckConstraint @schema @crops -Name 'CK_Crops_AllowedCrops' -Expression 'Name = ''Strawberries'' or Name = ''Rasberries'''
    Add-DefaultConstraint @schema @crops -ColumnName 'Name' -Expression '''Strawberries'''
    Add-Description @schema @crops -ColumnName 'Name' 'Yumm!'
    Add-ForeignKey @schema @crops -ColumnName 'FarmerID' -ReferencesSchema `$schema.SchemaName -References `$farmers.TableName -ReferencedColumn 'ID'
    Add-Index @schema @crops -ColumnName 'Name'
    Add-UniqueKey @schema @crops 'Name'

    Add-DataType @schema -Name 'GUID' -From 'uniqueidentifier'
    Add-Synonym -Name 'Crop' @schema -TargetSchemaName `$schema.SchemaName 'Crops'

    Add-StoredProcedure 'GetFarmers' @schema -Definition 'AS select * from Crops'
    Add-Trigger 'CropActivity' @schema -Definition "on idempotent.Crops after insert as return"
    Add-UserDefinedFunction 'GetInteger' @schema -Definition '(@Number int) returns int as begin return @Number end'
    Add-View 'FarmerCrops' @schema -Definition "as select Farmers.Name CropName, Crops.Name FarmersName from Crops join Farmers on Crops.FarmerID = Farmers.ID"

    Add-Table @schema 'removeme' {
        int 'ID' -Identity
    }

    Add-Schema 'empty'
}
"@ | New-Migration -Name 'RemoveOperations'

    Assert-ConvertMigration -Schemas -Schema -CodeObject -Data -DependentObject -ExtendedProperty -Trigger -Constraint -ForeignKey -Type

    try
    {
        $schema = @{ SchemaName = 'idempotent' }
        $crops = @{ TableName = 'Crops' }
        $farmers = @{ TableName = 'Farmers' }

        Assert-False (Test-CheckConstraint -Name 'CK_Crops_Allowed_Crops')
        Assert-False (Test-Column @schema @farmers -Name 'RemoveMe')
        Assert-False (Test-DataType @schema -Name 'GUID')
        Assert-False (Test-DefaultConstraint @schema @crops -ColumnName 'Name')
        Assert-False (Test-ExtendedProperty @schema @crops -ColumnName 'Name' -Name 'MS_Description')
        Assert-False (Test-ForeignKey @schema @crops -ReferencesSchema $schema.SchemaName -References $farmers.TableName)
        Assert-False (Test-Index @schema @crops -ColumnName 'Name')
        Assert-False (Test-PrimaryKey @schema @crops)
        Assert-False (Test-Schema -Name 'empty')
        Assert-False (Test-StoredProcedure @schema -Name 'GetFarmers')
        Assert-False (Test-Synonym @schema -Name 'Crop')
        Assert-False (Test-Table @schema -Name 'removeme')
        Assert-False (Test-Trigger @schema -Name 'CropActivity')
        Assert-False (Test-UniqueKey @schema @crops -ColumnName 'Name')
        Assert-False (Test-UserDefinedFunction @schema -Name 'GetInteger')
        Assert-False (Test-View @schema -Name 'FarmerCrops')
    }
    finally
    {
        Pop-ConvertedScripts
    }
}

function Test-ShouldCreateIdempotentQueriesForDisableOperations
{
    $migration = @"
function Push-Migration
{
    `$idempotent = @{ SchemaName = 'idempotent' }
    `$crops = @{ TableName = 'Crops' }
    `$farmers = @{ TableName = 'Farmers' }

    Add-Schema `$idempotent.SchemaName
    
    Add-Table @idempotent `$farmers.TableName {
        int 'ID' -NotNull
        varchar 'Name' -NotNull -Size 500
        varchar 'ZipCode' -Size 10
    }
    Add-PrimaryKey @idempotent @farmers -ColumnName 'ID'

    Add-Table @idempotent `$crops.TableName {
        int 'ID' -Identity
        varchar 'Name' -Size 50
        int 'FarmerID' -NotNull
    }
    Add-CheckConstraint @idempotent @crops -Name 'CK_Crops_AllowedCrops' -Expression 'Name = ''Strawberries'' or Name = ''Rasberries'''

    Add-ForeignKey @idempotent @crops -ColumnName 'FarmerID' -ReferencesSchema `$idempotent.SchemaName -References `$farmers.TableName -ReferencedColumn 'ID'
}

function Pop-Migration
{
    `$idempotent = @{ SchemaName = 'idempotent' }
    `$crops = @{ TableName = 'Crops' }
    `$farmers = @{ TableName = 'Farmers' }

    Remove-ForeignKey @idempotent @crops -Name '$(New-ForeignKeyConstraintName -SourceSchema 'idempotent' 'Crops' -TargetSchema 'idempotent' 'Farmers')' 
    Remove-Table @idempotent `$crops.TableName
    Remove-Table @idempotent `$farmers.TableName
    Remove-Schema `$idempotent.SchemaName
}
"@ | New-Migration -Name 'ShouldCreateIdempotentQueriesForDisableOperations'

    Invoke-RTRivet -Push 'ShouldCreateIdempotentQueriesForDisableOperations'

    $migration | Rename-Migration

    @"
function Push-Migration
{
    `$schema = @{ SchemaName = 'idempotent' }
    `$crops = @{ TableName = 'Crops' }
    `$farmers = @{ TableName = 'Farmers' }

    Disable-Constraint @schema @crops -Name 'CK_Crops_AllowedCrops'
    Disable-Constraint @schema @crops -Name '$(New-ForeignKeyConstraintName -SourceSchema 'idempotent' 'Crops' -TargetSchema 'idempotent' 'Farmers')'
}

function Pop-Migration
{
    `$schema = @{ SchemaName = 'idempotent' }
    `$crops = @{ TableName = 'Crops' }
    `$farmers = @{ TableName = 'Farmers' }

    Enable-Constraint @schema @crops -Name 'CK_Crops_AllowedCrops'
    Enable-Constraint @schema @crops -Name '$(New-ForeignKeyConstraintName -SourceSchema 'idempotent' 'Crops' -TargetSchema 'idempotent' 'Farmers')'
}
"@ | New-Migration -Name 'DisableOperations'

    Assert-ConvertMigration -Constraint 

    $schema = @{ SchemaName = 'idempotent' }
    $crops = @{ TableName = 'Crops' }
    $farmers = @{ TableName = 'Farmers' }

    Assert-CheckConstraint -Name 'CK_Crops_AllowedCrops' -Definition '([Name]=''Strawberries'' or [Name]=''Rasberries'')' -IsDisabled
    Assert-ForeignKey @schema @crops -ReferencesSchema $schema.SchemaName -References $farmers.TableName -IsDisabled
}

function Test-ShouldCreateIdempotentQueriesForEnableOperations
{
    $migration = @"
function Push-Migration
{
    `$idempotent = @{ SchemaName = 'idempotent' }
    `$crops = @{ TableName = 'Crops' }
    `$farmers = @{ TableName = 'Farmers' }

    Add-Schema `$idempotent.SchemaName
    
    Add-Table @idempotent `$farmers.TableName {
        int 'ID' -NotNull
        varchar 'Name' -NotNull -Size 500
        varchar 'ZipCode' -Size 10
    }
    Add-PrimaryKey @idempotent @farmers -ColumnName 'ID'

    Add-Table @idempotent `$crops.TableName {
        int 'ID' -Identity
        varchar 'Name' -Size 50
        int 'FarmerID' -NotNull
    }
    Add-CheckConstraint @idempotent @crops -Name 'CK_Crops_AllowedCrops' -Expression 'Name = ''Strawberries'' or Name = ''Rasberries'''
    Add-ForeignKey @idempotent @crops -ColumnName 'FarmerID' -ReferencesSchema `$idempotent.SchemaName -References `$farmers.TableName -ReferencedColumn 'ID'

    Disable-Constraint @idempotent @crops -Name 'CK_Crops_AllowedCrops'
    Disable-Constraint @idempotent @crops -Name '$(New-ForeignKeyConstraintName -SourceSchema 'idempotent' 'Crops' -TargetSchema 'idempotent' 'Farmers')'
}

function Pop-Migration
{
    `$idempotent = @{ SchemaName = 'idempotent' }
    `$crops = @{ TableName = 'Crops' }
    `$farmers = @{ TableName = 'Farmers' }

    Enable-Constraint @idempotent @crops -Name 'CK_Crops_AllowedCrops'
    Enable-Constraint @idempotent @crops -Name '$(New-ForeignKeyConstraintName -SourceSchema 'idempotent' 'Crops' -TargetSchema 'idempotent' 'Farmers')'
    Remove-ForeignKey @idempotent @crops -Name '$(New-ForeignKeyConstraintName -SourceSchema 'idempotent' 'Crops' -TargetSchema 'idempotent' 'Farmers')'
    Remove-Table @idempotent `$crops.TableName
    Remove-Table @idempotent `$farmers.TableName
    Remove-Schema `$idempotent.SchemaName
}
"@ | New-Migration -Name 'ShouldCreateIdempotentQueriesForEnableOperations'

    Invoke-RTRivet -Push 'ShouldCreateIdempotentQueriesForEnableOperations'

    $migration | Rename-Migration

    @"
function Push-Migration
{
    `$schema = @{ SchemaName = 'idempotent' }
    `$crops = @{ TableName = 'Crops' }
    `$farmers = @{ TableName = 'Farmers' }

    Enable-Constraint @schema @crops -Name 'CK_Crops_AllowedCrops'
    Enable-Constraint @schema @crops -Name '$(New-ForeignKeyConstraintName -SourceSchema 'idempotent' 'Crops' -TargetSchema 'idempotent' 'Farmers')'
}

function Pop-Migration
{
    `$schema = @{ SchemaName = 'idempotent' }
    `$crops = @{ TableName = 'Crops' }
    `$farmers = @{ TableName = 'Farmers' }

    Disable-Constraint @schema @crops -Name 'CK_Crops_AllowedCrops'
    Disable-Constraint @schema @crops -Name '$(New-ForeignKeyConstraintName -SourceSchema 'idempotent' 'Crops' -TargetSchema 'idempotent' 'Farmers')'
}
"@ | New-Migration -Name 'DisableOperations'

    Assert-ConvertMigration -Constraint

    $schema = @{ SchemaName = 'idempotent' }
    $crops = @{ TableName = 'Crops' }
    $farmers = @{ TableName = 'Farmers' }

    Assert-CheckConstraint -Name 'CK_Crops_AllowedCrops' -Definition '([Name]=''Strawberries'' or [Name]=''Rasberries'')'
    Assert-ForeignKey @schema @crops -ReferencesSchema $schema.SchemaName -References $farmers.TableName
}

function Test-ShouldMakeInsertUpdateQueriesIdempotent
{
    @'
function Push-Migration
{
    Add-Schema 'idempotent'
    
    Add-Table -SchemaName 'idempotent' 'Idempotent' {
        int 'ID' -NotNull
        varchar 'Name' -Size 50 -NotNull
        varchar 'Optional' -Size 50
    }
    Add-PrimaryKey -SchemaName 'idempotent' -TableName 'Idempotent' -Column 'ID'

    Add-Row -SchemaName 'idempotent' -TableName 'Idempotent' -Column @{ ID = 1; Name = 'First' } 
    Update-Row -SchemaName 'idempotent' -TableName 'Idempotent' -Column @{ Optional = 'Value' } -Where 'ID = 1'
}

function Pop-Migration
{
    Remove-Table -SchemaName 'idempotent' 'Idempotent'
    Remove-Schema 'idempotent'
}
'@ | New-Migration -Name 'DataOperations'

    Assert-ConvertMigration -Schemas -Schema -Data

    try
    {
        Assert-Row -SchemaName 'idempotent' -TableName 'Idempotent' -Column @{ ID = 1 ; Name = 'First' ; Optional = 'Value' } -Where 'ID = 1'
    }
    finally
    {
        Pop-ConvertedScripts
    }
}


function Test-ShouldRunPlugins
{
    Get-Item -Path (Join-Path -Path $TestDir -ChildPath '..\Rivet\Extras\*-MigrationOperation.ps1') |
        Copy-Item -Destination $pluginsPath
    
    @'
function Push-Migration
{
    Add-Table 'NeedsPluginStuff' -Description "test" {
        int 'ID' -NotNull -Description "test"
    }
}

function Pop-Migration
{
    Remove-Table 'NeedsPluginStuff'
}
'@ | New-Migration -Name 'ShouldRunPlugins'

    Assert-ConvertMigration -Schema -ExtendedProperty -Trigger 

    try
    {
        Assert-Table 'NeedsPluginStuff'
        Assert-Column -TableName 'NeedsPluginStuff' -Name 'CreateDate' -DataType 'smalldatetime' -NotNull
        Assert-Column -TableName 'NeedsPluginStuff' -Name 'LastUpdated' -DataType 'datetime' -NotNull
        Assert-Column -TableName 'NeedsPluginStuff' -Name 'rowguid' -DataType 'uniqueIdentifier' -NotNull -RowGuidCol
        Assert-Column -TableName 'NeedsPluginStuff' -Name 'SkipBit' -DataType 'bit'
        Assert-Trigger 'trNeedsPluginStuff_Activity'
        Assert-Index -TableName 'NeedsPluginStuff' -ColumnName 'rowguid' -Unique
    }
    finally
    {
        Pop-ConvertedScripts
    }
}

function Test-ShouldIncludeAuthorInOutputScripts
{
   $migrationOne = @'
function Push-Migration
{
    Add-Table 'TableOne' {
        int 'ID' -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'TableOne'
}
'@ | New-Migration -Name 'CreateTableOne'

   $migrationTwo = @'
function Push-Migration
{
    Add-Table 'TableTwo' {
        int 'ID' -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'TableTwo'
}
'@ | New-Migration -Name 'CreateTableTwo'

    try
    {
        Assert-ConvertMigration -Schema -Author @{ $migrationOne.BaseName = 'Joe Cool' }

        Assert-Table 'TableOne'
        Assert-Table 'TableTwo'
    }
    finally
    {
        Pop-ConvertedScripts
    }
}

function Test-ShouldAggregateChanges
{
    @'
function Push-Migration
{
    Add-Schema 'aggregate'

    Add-Table -SchemaName 'aggregate' 'Beta' {
        int 'ID' -NotNull
        nvarchar 'Name' -Size 50
        nvarchar 'RemoveMe' -Size 10
    }

    Add-PrimaryKey -SchemaName 'aggregate' -TableName 'Beta' -ColumnName 'ID'
}

function Pop-Migration
{
    Remove-Table -SchemaName 'aggregate' 'Beta'
    Remove-Schema 'aggregate'
}
'@ | New-Migration -Name 'AddTables'

    @"
function Push-Migration
{
    Remove-PrimaryKey -SchemaName 'aggregate' -TableName 'Beta' -Name '$(New-ConstraintName -PrimaryKey -SchemaName 'aggregate' -TableName 'Beta')'
    Add-PrimaryKey -SchemaName 'aggregate' -TableName 'Beta' -ColumnName 'Name'

    Update-Table -SchemaName 'aggregate' 'Beta' -UpdateColumn {
        nvarchar 'Name' -Size 500 -NotNull
    }

    Update-Table -SchemaName 'aggregate' 'Beta' -AddColumn {
        nvarchar 'LastName' -Size 50
    }

    Update-Table -SchemaName 'aggregate' 'Beta' -UpdateColumn {
        nvarchar 'LastName' -Size 500 -NotNull
    }

    Update-Table -SchemaName 'aggregate' 'Beta' -RemoveColumn 'RemoveMe'
}

function Pop-Migration
{
    Remove-PrimaryKey -SchemaName 'aggregate' -TableName 'Beta' -Name '$(New-ConstraintName -PrimaryKey -SchemaName 'aggregate' -TableName 'Beta')'
}
"@ | New-Migration -Name 'UpdateTables'

    Assert-ConvertMigration -Schemas -Schema

    try
    {
        $schemaPath = Join-Path -Path $outputDir -ChildPath ('{0}.Schema.sql' -f $RTDatabaseName)
        $content = Get-Content -Path $schemaPath -Raw
        $expectedQuery = @'
create table [aggregate].[Beta] (
    [ID] int not null,
    [Name] nvarchar(500) not null,
    [LastName] nvarchar(500) not null
)
'@
        Assert-Query -Schema -ExpectedQuery $expectedQuery

        $expectedQuery = 'alter table [aggregate].[Beta] add constraint [PK_aggregate_Beta] primary key clustered ([Name])'
        Assert-Query -Schema -ExpectedQuery $expectedQuery 

        $expectedQuery = 'alter table [aggregate].[Beta] add constraint [PK_aggregate_Beta] primary key clustered ([ID])'
        Assert-Query -Schema -ExpectedQuery $expectedQuery -NotExists

        Assert-PrimaryKey -SchemaName 'aggregate' -TableName 'Beta' -ColumnName 'Name'
    }
    finally
    {
        Pop-ConvertedScripts
    }
}

function Test-ShouldAggregateMultipleTableUpdates
{
    $migration = @'
function Push-Migration
{
    Add-Table 'FeedbackLog' {
        int 'ID' -NotNull
        varchar 'Feedback' -NotNull -Size 1008
    }
    Add-PrimaryKey 'FeedbackLog' -ColumnName 'ID'
}

function Pop-Migration
{
    Remove-Table 'FeedbackLog'
}
'@ | New-Migration -Name 'ShouldAggregateMultipleTableUpdates'

    Invoke-RTRivet -Push 'ShouldAggregateMultipleTableUpdates'

    Assert-Table -Name 'FeedbackLog'
    $migration | Rename-Migration

    @'
function Push-Migration
{
    Update-Table -Name 'FeedbackLog' -AddColumn {
        varchar 'ToBeIncreased' -Size 50 -NotNull
        varchar 'ToBeRemoved' -Size 100 -NotNull
    }

    # Yes.  Keep these separate.  That's what we're testing.
    Update-Table -Name 'FeedbackLog' -UpdateColumn { 
        VarChar 'Feedback' -Size 3000 
        varchar 'ToBeIncreased' -Size 200
    }

    Update-Table -Name 'FeedbackLog' -RemoveColumn 'ToBeRemoved'

}

function Pop-Migration
{
    Update-Table -Name 'FeedbackLog' -UpdateColumn { VarChar 'Feedback' 1008 }
    Update-Table -Name 'FeedbackCategories' -RemoveColumn 'ToBeIncreased','ToBERemoved'
}
'@ | New-Migration -Name 'RemoveOperations'

    Assert-ConvertMigration -Schema

    Assert-Query -Schema -ExpectedQuery 'alter table [dbo].[FeedbackLog] add [ToBeIncreased] varchar(200)'
    Assert-Query -Schema -ExpectedQuery 'alter table [dbo].[FeedbackLog] alter column [Feedback] varchar(3000)'
    Assert-Query -Schema -ExpectedQuery '[ToBeRemoved]' -NotExists
    Assert-Query -Schema -NotExists -ExpectedQuery "alter table [dbo].[FeedbackLog] alter column [ToBeIncreased] varchar(200)`r`nGO"
}

function Test-ShouldAggregateTableAndColumnRenames
{
    @'
function Push-Migration
{
    Add-Table 'T1' {
        int 'C1' -NotNull
        varchar 'C2' -NotNull -Size 1008
    }

    Rename-Column 'T1' 'C1' 'C1New'
    Rename-Column 'T1' 'C2' 'C2New'
    Rename-Object 'T1' 'T1New'
}

function Pop-Migration
{
    Remove-Table 'T1New'
}
'@ | New-Migration -Name 'AddT1'

    Invoke-RTRivet -Push 'AddT1'

    Assert-Table -Name 'T1New'

    Assert-ConvertMigration -Schema

    Assert-Query -Schema -ExpectedQuery 'create table [dbo].[T1New]'
    Assert-Query -Schema -ExpectedQuery '[C1New] int not null'
    Assert-Query -Schema -ExpectedQuery '[C2New] varchar(1008) not null'
    Assert-Query -Schema -NotExists -ExpectedQuery "sp_rename"
}

function Test-ShouldExcludeMigrations
{
    @'
function Push-Migration
{
    Add-Schema 'include'
}

function Pop-Migration
{
    Remove-Schema 'include'
}
'@ | New-Migration -Name 'Include'

    @'
function Push-Migration
{
    Add-Schema 'exclude'
}

function Pop-Migration
{
    Remove-Schema 'exclude'
}
'@ | New-Migration -Name 'Exclude'

    Assert-ConvertMigration -Schemas -Exclude '*Exc*'

    try
    {
        Assert-Schema 'include'
        Assert-False (Test-Schema 'exclude')
    }
    finally
    {
        Pop-ConvertedScripts
    }
}

function Test-ShouldIncludeMigrations
{
    @'
function Push-Migration
{
    Add-Schema 'include'
}

function Pop-Migration
{
    Remove-Schema 'include'
}
'@ | New-Migration -Name 'Include'

    @'
function Push-Migration
{
    Add-Schema 'exclude'
}

function Pop-Migration
{
    Remove-Schema 'exclude'
}
'@ | New-Migration -Name 'Exclude'

    Assert-ConvertMigration -Schemas -Include '*Inc*'

    try
    {
        Assert-Schema 'include'
        Assert-False (Test-Schema 'exclude')
    }
    finally
    {
        Pop-ConvertedScripts
    }
}

function Test-ShouldExcludeMigrationsBeforeDate
{
    $m1 = & $rivetPath -New -Name 'Include' -ConfigFilePath $RTConfigFilePath
    @'
function Push-Migration
{
    Add-Schema 'include'
}

function Pop-Migration
{
    Remove-Schema 'include'
}
'@ | Set-Content -Path $m1.FullName

    $before = Get-Date
    Start-Sleep -Seconds 1

    $m2 = & $rivetPath -New -Name 'Exclude' -ConfigFilePath $RTConfigFilePath
    @'
function Push-Migration
{
    Add-Schema 'exclude'
}

function Pop-Migration
{
    Remove-Schema 'exclude'
}
'@ | Set-Content -Path $m2.FullName

    Assert-ConvertMigration -Schemas -Before $before

    try
    {
        Assert-Schema 'include'
        Assert-False (Test-Schema 'exclude')
    }
    finally
    {
        Pop-ConvertedScripts
    }
}

function Test-ShouldExcludeMigrationsAfterDate
{
    $m1 = & $rivetPath -New -Name 'Exclude' -ConfigFilePath $RTConfigFilePath

    @'
function Push-Migration
{
    Add-Schema 'exclude'
}

function Pop-Migration
{
    Remove-Schema 'exclude'
}
'@ | Set-Content -Path $m1.FullName

    Start-Sleep -Seconds 1

    $after = Get-Date

    $m2 = & $rivetPath -New -Name 'Include' -ConfigFilePath $RTConfigFilePath

    @'
function Push-Migration
{
    Add-Schema 'include'
}

function Pop-Migration
{
    Remove-Schema 'include'
}
'@ | Set-Content -Path $m2.FullName

    Assert-ConvertMigration -Schemas -After $after

    try
    {
        Assert-Schema 'include'
        Assert-False (Test-Schema 'exclude')
    }
    finally
    {
        Pop-ConvertedScripts
    }
}

function Test-ShouldHandleRemovingThenAddingColumn
{
    @'
function Push-Migration
{
    Update-Table -Name EligibilityMaps -RemoveColumn 'UsePgpEncryption'
    Update-Table -Name EligibilityMaps -RemoveColumn 'Delimiter'
    Update-Table -Name EligibilityMaps -AddColumn { Bit 'UsePgpEncryption' -Description 'is the file expected to be encrypted?' }
    Update-Table -Name EligibilityMaps -AddColumn { char 'Delimiter' -Size 1 -Description 'what is the delimiter to use when processing the file. valid values are: [,|\t]' }
}

function Pop-Migration
{
    Update-Table -Name EligibilityMaps -RemoveColumn 'UsePgpEncryption'
    Update-Table -Name EligibilityMaps -RemoveColumn 'Delimiter'
    Update-Table -Name EligibilityMaps -AddColumn { Bit 'UsePgpEncryption' -Description 'is the file expected to be encrypted?' }
    Update-Table -Name EligibilityMaps -AddColumn { varchar 'Delimiter' -Size 5 -Description 'what is the delimiter to use when processing the file. valid values are: [,|\t]' }
}
'@ | New-Migration -Name 'RemoveThenReAdd'

    & $convertRivetMigration -ConfigFilePath $RTConfigFilePath -OutputPath $outputDir
    Assert-NoError
    $sql = Get-Content -Path (Join-Path -Path $outputDir -ChildPath ('{0}.Schema.sql' -f $RTDatabaseName)) -Raw
    Assert-True ($sql -notmatch 'drop column') 'SQL Contains drop column statements'
}


function Assert-ConvertMigration
{
    [CmdletBinding()]
    param(
        [string]
        $DatabaseName = $RTDatabaseName,
        
        [Switch]
        $Schemas,

        [Switch]
        $Schema,

        [Switch]
        $DependentObject,

        [Switch]
        $CodeObject,

        [Switch]
        $ExtendedProperty,

        [Switch]
        $Data,

        [Switch]
        $Unknown,

        [Switch]
        $Trigger,

        [Switch]
        $Constraint,

        [Switch]
        $ForeignKey,

        [Switch]
        $Type,

        [string[]]
        $Include,

        [string[]]
        $Exclude,

        [DateTime]
        $Before,

        [DateTime]
        $After,

        [Hashtable]
        $Author
    )

    $convertRivetMigrationParams = @{ }
    @( 'Exclude', 'Include', 'Before', 'After' ) |
        Where-Object { $PSBoundParameters.ContainsKey( $_ ) } |
        ForEach-Object { $convertRivetMigrationParams.$_ = Get-Variable -Name $_ -ValueOnly }

    if( $Author )
    {
        $convertRivetMigrationParams.Author = $Author
    }

    & $convertRivetMigration -ConfigFilePath $RTConfigFilePath -OutputPath $outputDir @convertRivetMigrationParams -Verbose:$VerbosePreference

    ('Schemas','Schema','DependentObject','ExtendedProperty','CodeObject','Data','Unknown','Trigger','Constraint','ForeignKey','Type') | ForEach-Object {
        $shouldExist = Get-Variable -Name $_ -ValueOnly
        $path = Join-Path -Path $outputDir -ChildPath ('{0}.{1}.sql' -f $DatabaseName,$_)
        Assert-Equal $shouldExist (Test-Path -Path $path) ('test if output file ''{0}'' exists' -f $path)
        if( $shouldExist -and $Author )
        {
            $content = Get-Content -Path $path -Raw
            $Author.Keys | ForEach-Object {
                $signature = '*-- {0}: {1}*' -f $_,$Author[$_]
                Assert-Like $content $signature ('''{0}'' missing author signature ''{1}''' -f $path,$signature)
            }
        }
    }

    Invoke-ConvertedScripts
}

function Assert-Query
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The query.
        $ExpectedQuery,

        [Parameter(Mandatory=$true,ParameterSetName='Schema')]
        [Switch]
        # Assert the query is in the schema file.
        $Schema,

        [Switch]
        # Check that the query *doesn't* exist.
        $NotExists
    )

    $scriptPath = Join-Path -Path $outputDir -ChildPath ('{0}.{1}.sql' -f $RTDatabaseName,$PSCmdlet.ParameterSetName)
    $content = Get-Content -Path $scriptPath -Raw
    $contains = $content.Contains( $ExpectedQuery )
    if( $NotExists )
    {
        Assert-False $contains ("`nIn {0}:`n{1}`ncontains`n`n{2}" -f $scriptPath,$content,$ExpectedQuery)
    }
    else
    {
        Assert-True $contains ("`nIn {0}:`n{1}`ndoes not contain`n`n{2}" -f $scriptPath,$content,$ExpectedQuery)
    }
}

function Invoke-ConvertedScripts
{
    $ranConvertedScripts = $false
    Invoke-Command {
            Get-ChildItem -Path $outputDir -Filter '*.Schemas.sql'
            Get-ChildItem -Path $outputDir -Filter '*.Schema.sql'
            Get-ChildItem -Path $outputDir -Filter '*.DependentObject.sql'
            Get-ChildItem -Path $outputDir -Filter '*.CodeObject.sql'
            Get-ChildItem -Path $outputDir -Filter '*.ExtendedProperty.sql'
            Get-ChildItem -Path $outputDir -Filter '*.Data.sql'
            Get-ChildItem -Path $outputDir -Filter '*.Trigger.sql'
            Get-ChildItem -Path $outputDir -Filter '*.Constraint.sql'
            Get-ChildItem -Path $outputDir -Filter '*.ForeignKey.sql'
            Get-ChildItem -Path $outputDir -Filter '*.Type.sql'

        } |
        ForEach-Object {
            $ranConvertedScripts = $true
            $file = $_
            try
            {
                # Run 'em twice.  Make sure they really *are* idempotent.
                Write-Verbose (Get-Content -Raw -Path $_.FullName)
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

function Pop-ConvertedScripts
{
    param(
        [string]
        $DatabaseName = $RTDatabaseName
    )

    Get-Migration -ConfigFilePath $RTConfigFilePath -Database $DatabaseName |
        Select-Object -ExpandProperty 'PopOperations' |
        ForEach-Object { 
            $query = $_.ToIdempotentQuery()
            Write-Verbose $query
            Invoke-RivetTestQuery -Query $query
        }

}

function Rename-Migration
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [Alias('FullName')]
        [string]
        $Path
    )

    begin
    {
        Set-StrictMode -Version 'Latest'
    }

    process
    {
        Rename-Item -Path $Path -NewName ('{0}.off' -f (Split-Path -Leaf -Path $Path))
    }
}