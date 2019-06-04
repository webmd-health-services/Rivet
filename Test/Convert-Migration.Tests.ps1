
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

$rivetPath = Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\rivet.ps1' -Resolve
$convertRivetMigration = Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\RivetSamples\Convert-Migration.ps1' -Resolve
$outputDir = $null
$testedOperations = @{ }
$testsRun = 0

function Global:Watch-Operation
{
    [CmdletBinding()]
    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
    param(
        $Migration,
        $Operation
    )
    $testedOperations[$Operation.GetType()] = $true
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
    
    $timer = New-Object 'Diagnostics.Stopwatch'
    $timer.Start()
    & $convertRivetMigration -ConfigFilePath $RTConfigFilePath -OutputPath $outputDir @convertRivetMigrationParams -Verbose:$VerbosePreference
    $timer.Stop()
    Write-Verbose ('{0}  {1}' -f $timer.Elapsed,$convertRivetMigration)
    
    $receivedParameters = $PSBoundParameters
    ('Schemas','Schema','DependentObject','ExtendedProperty','CodeObject','Data','Unknown','Trigger','Constraint','ForeignKey','Type') | ForEach-Object {
        $shouldExist = Get-Variable -Name $_ -ValueOnly
        $path = Join-Path -Path $outputDir -ChildPath ('{0}.{1}.sql' -f $DatabaseName,$_)
        if( $shouldExist )
        {
            $path | Should -Exist
        }
        else
        {
            $path | Should -Not -Exist
        }
        if( $shouldExist -and $Author )
        {
            $content = Get-Content -Path $path -Raw
            $Author.Keys | ForEach-Object {
                $signature = '*-- {0}: {1}*' -f $_,$Author[$_]
                $content | Should -BeLike $signature -Because ('''{0}'' missing author signature ''{1}''' -f $path,$signature)
            }
        }
    }
    
    Invoke-ConvertedScripts -DatabaseName $DatabaseName
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
        $contains | Should -BeFalse
    }
    else
    {
        $contains | Should -BeTrue
    }
}
    
function Disable-Migration
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
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

function Enable-Migration
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
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
        $filename = Split-Path -Leaf -Path $Path
        Rename-Item -Path ('{0}.off' -f $Path) -NewName $filename
    }
}

function Init
{
    $timer = New-Object 'Diagnostics.Stopwatch'
    $timer.Start()

    $Global:Error.Clear()
    Get-ChildItem -Path $TestDrive.FullName | Remove-Item -Recurse -Force

    Start-RivetTest -DatabaseName $RTDatabaseName,$RTDatabase2Name
    
    $script:outputDir = Join-Path -Path $TestDrive.FullName -ChildPath 'output'
    if( -not (Test-Path -Path $outputDir -PathType Container) )
    {
        New-Item -Path $outputDir -ItemType 'Directory' | Out-Null
    }

    ++$script:testsRun
    
    Invoke-RTRivet -Push -Database $RTDatabaseName,$RTDatabase2Name
    
    & (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Import-Rivet.ps1' -Resolve)

    $timer.Stop()
    Write-Verbose -Message ('{0}  Init' -f $timer.Elapsed)
}

function Invoke-ConvertedScripts
{
    param(
        [string]
        $DatabaseName = $RTDatabaseName
    )

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
        Where-Object { $_.Name -like ('{0}.*' -f $DatabaseName) } |
        ForEach-Object {
            $ranConvertedScripts = $true
            $file = $_
            try
            {
                # Run 'em twice.  Make sure they really *are* idempotent.
                Write-Verbose (Get-Content -Raw -Path $_.FullName)
                $result = sqlcmd.exe -S $RTServer -d $DatabaseName -E -i $_.FullName
                $LASTEXITCODE | Should -Be 0
                $result | Format-Table -AutoSize
    
                $result = sqlcmd.exe -S $RTServer -d $DatabaseName -E -i $_.FullName
                $LASTEXITCODE | Should -Be 0
                $result | Format-Table -AutoSize
            }
            catch
            {
                throw ('{0} failed to execute: {1}' -f $file.Name,$_.Exception.Message)
            }
        }
    $ranConvertedScripts | Should -BeTrue
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
            Invoke-RivetTestQuery -Query $query -DatabaseName $DatabaseName
        }
}
    
function Reset
{
    $timer = New-Object 'Diagnostics.Stopwatch'
    $timer.Start()

    try
    {
        Stop-RivetTest -DatabaseName $RTDatabaseName,$RTDatabase2Name
        Write-Verbose ('{0}  Reset  Successfully cleaned up.' -f $timer.Elapsed)
    }
    catch
    {
        Write-Verbose ('{0}  Reset  Failures cleaning up.' -f $timer.Elapsed)
        # These tests sometimes don't use migrations to muck about with the database, so ignore any errors.
    }

    if( (Get-Module 'RivetSamples') )
    {
        Remove-Module 'RivetSamples' -Force
        Write-Verbose ('{0}  Reset  Removed RivetSamples' -f $timer.Elapsed)
    }

    $timer.Stop()
    Write-Verbose -Message ('{0}  Reset' -f $timer.Elapsed)
}

Describe 'Convert-Migration.when output path doesn''t exist' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should create output path' {
        $outputPath = Join-Path -Path $TestDrive.FullName -ChildPath ([IO.Path]::GetRandomFileName())
        $outputPath | Should -Not -Exist
        & $convertRivetMigration -OutputPath $outputPath -ConfigFilePath $RTConfigFilePath
        $Global:Error.Count | Should -Be 0
        $outputPath | Should -Exist
    }
}

Describe 'Convert-Migration.when exporting migrations for multiple databases' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should create scripts for database' {
        $migrationAPath = Join-Path -Path $RTDatabasesRoot -ChildPath ('{0}\Migrations\20000000000001_A.ps1' -f $RTDatabaseName)
        $migrationBPath = Join-Path -Path $RTDatabasesRoot -ChildPath ('{0}\Migrations\20000000000002_B.ps1' -f $RTDatabaseName)
        $migrationA2Path = Join-Path -Path $RTDatabasesRoot -ChildPath ('{0}\Migrations\20000000000001_A.ps1' -f $RTDatabase2Name)
        New-Item -Path $migrationAPath -ItemType 'File' -Force
        New-Item -Path $migrationBPath -ItemType 'File'
        New-Item -Path $migrationA2Path -ItemType 'File' -Force
    
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
'@ | Set-Content -Path $migrationAPath
    
    @'
    function Push-Migration
    {
        Add-ExtendedProperty 'MS_Description' 'Umm, a view.' -ViewName 'vwT'
    }
    
    function Pop-Migration
    {
        Remove-ExtendedProperty 'MS_Description' -ViewName 'vwT'
    }
'@ | Set-Content -Path $migrationBPath
    
    
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
'@ | Set-Content -Path $migrationA2Path
    
        Assert-ConvertMigration -DatabaseName $RTDatabaseName -Schema -CodeObject -Data -ExtendedProperty
        $Global:Error.Count | Should -Be 0
        Assert-ConvertMigration -DatabaseName $RTDatabase2Name -Schemas -CodeObject
        $Global:Error.Count | Should -Be 0
    
        try
        {
            Assert-Table -Name 'T' -Description 'Umm, a table.'
            Assert-Column -TableName 'T' -Name 'ID' -DataType 'int' -NotNull -Increment 1 -Seed 1 -Description 'Umm, a column.'
            Assert-Column -TableName 'T' -Name 'C' -DataType 'varchar' -NotNull -Size 50 -Description 'Umm, another column.'
            Assert-View -Name 'vwT' -Description 'Umm, a view.'
            (Invoke-RivetTestQuery -Query 'select ID, C from [T]') | Should -Not -BeNullOrEmpty
            (Invoke-RivetTestQuery -Query 'select * from sys.schemas where name = ''s''' -DatabaseName $RTDatabase2Name) | Should -Not -BeNullOrEmpty
            Assert-StoredProcedure -SchemaName 's' -Name 'prcT' -DatabaseName $RTDatabase2Name
    
            [string[]]$lines = Get-Content -Path (Join-Path $outputDir ('{0}.ExtendedProperty.sql' -f $RTDatabaseName)) | 
                               Where-Object { $_ -match 'Umm, a view' }
            $lines.Count | Should -Be 1
        }
        finally
        {
            Pop-ConvertedScripts -Database $RTDatabaseName
            Pop-ConvertedScripts -Database $RTDatabase2Name
        }         
    }
}

Describe 'Convert-Migration.when scripts are run multiple times' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should create idempotent query for add operations' {
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
'@ | New-TestMigration -Name 'ShouldCreateIdempotentQueryForAddOperations'
    
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
            (Invoke-RivetTestQuery -Query ('select * from {0}.{1} where ID = 1 and Name = ''Blackbird''' -f $schema.SchemaName,$farmers.TableName)) | Should -Not -BeNullOrEmpty
        
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
            (Test-Schema 'convertmigrationquery') | Should -BeFalse
    
            $scriptQuery = Get-Content -Path (Join-Path $outputDir -ChildPath ('{0}.Unknown.sql' -f $RTDatabaseName)) |
                                Where-Object { $_ -match 'sp_executesql N''convertmigrationquery''' }
            $scriptQuery | Should -Not -BeNullOrEmpty
        }
        finally
        {
            Pop-ConvertedScripts
        }
    
    }
}

Describe 'Convert-Migration.when converted pop operations are run multiple times' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should create idempotent queries for remove operations' {
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
"@ | New-TestMigration -Name 'ShouldCreateIdempotentQueriesForRemoveOperations'
    
        Invoke-RTRivet -Push 'ShouldCreateIdempotentQueriesForRemoveOperations'
    
        Assert-Table -SchemaName 'idempotent' -Name 'removeme'
        $migration | Disable-Migration
    
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
"@ | New-TestMigration -Name 'RemoveOperations'
    
        Assert-ConvertMigration -Schemas -Schema -CodeObject -Data -DependentObject -ExtendedProperty -Trigger -Constraint -ForeignKey -Type
    
        try
        {
            $schema = @{ SchemaName = 'idempotent' }
            $crops = @{ TableName = 'Crops' }
            $farmers = @{ TableName = 'Farmers' }
    
            (Test-CheckConstraint -Name 'CK_Crops_Allowed_Crops') | Should -BeFalse
            (Test-Column @schema @farmers -Name 'RemoveMe') | Should -BeFalse
            (Test-DataType @schema -Name 'GUID') | Should -BeFalse
            (Test-DefaultConstraint @schema @crops -ColumnName 'Name') | Should -BeFalse
            (Test-ExtendedProperty @schema @crops -ColumnName 'Name' -Name 'MS_Description') | Should -BeFalse
            (Test-ForeignKey @schema @crops -ReferencesSchema $schema.SchemaName -References $farmers.TableName) | Should -BeFalse
            (Test-Index @schema @crops -ColumnName 'Name') | Should -BeFalse
            (Test-PrimaryKey @schema @crops) | Should -BeFalse
            (Test-Schema -Name 'empty') | Should -BeFalse
            (Test-StoredProcedure @schema -Name 'GetFarmers') | Should -BeFalse
            (Test-Synonym @schema -Name 'Crop') | Should -BeFalse
            (Test-Table @schema -Name 'removeme') | Should -BeFalse
            (Test-Trigger @schema -Name 'CropActivity') | Should -BeFalse
            (Test-UniqueKey @schema @crops -ColumnName 'Name') | Should -BeFalse
            (Test-UserDefinedFunction @schema -Name 'GetInteger') | Should -BeFalse
            (Test-View @schema -Name 'FarmerCrops') | Should -BeFalse
        }
        finally
        {
            Pop-ConvertedScripts
        }
    }
}

Describe 'Convert-Migration.when migrations contain operations that disable objects' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should create idempotent queries for disable operations' {
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
"@ | New-TestMigration -Name 'ShouldCreateIdempotentQueriesForDisableOperations'
    
        Invoke-RTRivet -Push 'ShouldCreateIdempotentQueriesForDisableOperations'
    
        $migration | Disable-Migration
    
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
"@ | New-TestMigration -Name 'DisableOperations'
    
        Assert-ConvertMigration -Constraint 
    
        $schema = @{ SchemaName = 'idempotent' }
        $crops = @{ TableName = 'Crops' }
        $farmers = @{ TableName = 'Farmers' }
    
        Assert-CheckConstraint -Name 'CK_Crops_AllowedCrops' -Definition '([Name]=''Strawberries'' or [Name]=''Rasberries'')' -IsDisabled
        Assert-ForeignKey @schema @crops -ReferencesSchema $schema.SchemaName -References $farmers.TableName -IsDisabled
    }
}

Describe 'Convert-Migration.when migrations contains operatins that enable objects' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should create idempotent queries for enable operations' {
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
"@ | New-TestMigration -Name 'ShouldCreateIdempotentQueriesForEnableOperations'
    
        Invoke-RTRivet -Push 'ShouldCreateIdempotentQueriesForEnableOperations'
    
        $migration | Disable-Migration
    
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
"@ | New-TestMigration -Name 'DisableOperations'
    
        Assert-ConvertMigration -Constraint
    
        $schema = @{ SchemaName = 'idempotent' }
        $crops = @{ TableName = 'Crops' }
        $farmers = @{ TableName = 'Farmers' }
    
        Assert-CheckConstraint -Name 'CK_Crops_AllowedCrops' -Definition '([Name]=''Strawberries'' or [Name]=''Rasberries'')'
        Assert-ForeignKey @schema @crops -ReferencesSchema $schema.SchemaName -References $farmers.TableName
    }
}

Describe 'Convert-Migration.when migrations contain row operations' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should make insert update queries idempotent' {
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
'@ | New-TestMigration -Name 'DataOperations'
    
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
}

Describe 'Convert-Migration.when there are plugins' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should run plugins' {
        Set-PluginPath -PluginPath (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\RivetSamples')
        
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
'@ | New-TestMigration -Name 'ShouldRunPlugins'
    
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
}

Describe 'Convert-Migration.when author is passed as a parameter' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should include author in output scripts' {
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
'@ | New-TestMigration -Name 'CreateTableOne'
    
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
'@ | New-TestMigration -Name 'CreateTableTwo'
    
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
}

Describe 'Convert-Migration.when there are operations for the same object across migrations' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should aggregate changes' {
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
'@ | New-TestMigration -Name 'AddTables'
    
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
"@ | New-TestMigration -Name 'UpdateTables'
    
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
}

Describe 'Convert-Migration.when multiple operations touch the same table' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should aggregate multiple table updates' {
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
'@ | New-TestMigration -Name 'ShouldAggregateMultipleTableUpdates'
    
        Invoke-RTRivet -Push 'ShouldAggregateMultipleTableUpdates'
    
        Assert-Table -Name 'FeedbackLog'
        $migration | Disable-Migration
    
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
'@ | New-TestMigration -Name 'RemoveOperations'
    
        Assert-ConvertMigration -Schema
    
        Assert-Query -Schema -ExpectedQuery 'alter table [dbo].[FeedbackLog] add [ToBeIncreased] varchar(200)'
        Assert-Query -Schema -ExpectedQuery 'alter table [dbo].[FeedbackLog] alter column [Feedback] varchar(3000)'
        Assert-Query -Schema -ExpectedQuery '[ToBeRemoved]' -NotExists
        Assert-Query -Schema -NotExists -ExpectedQuery "alter table [dbo].[FeedbackLog] alter column [ToBeIncreased] varchar(200)`r`nGO"
    }
}

Describe 'Convert-Migration.when table and columns get renamed' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should aggregate table and column renames' {
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
'@ | New-TestMigration -Name 'AddT1'
    
        Invoke-RTRivet -Push 'AddT1'
    
        Assert-Table -Name 'T1New'
    
        Assert-ConvertMigration -Schema
    
        Assert-Query -Schema -ExpectedQuery 'create table [dbo].[T1New]'
        Assert-Query -Schema -ExpectedQuery '[C1New] int not null'
        Assert-Query -Schema -ExpectedQuery '[C2New] varchar(1008) not null'
        Assert-Query -Schema -NotExists -ExpectedQuery "sp_rename"
    }
}

Describe 'Convert-Migration.when excluding certain operations' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should exclude migrations' {
        @'
    function Push-Migration
    {
        Add-Schema 'include'
    }
    
    function Pop-Migration
    {
        Remove-Schema 'include'
    }
'@ | New-TestMigration -Name 'Include'
    
        @'
    function Push-Migration
    {
        Add-Schema 'exclude'
    }
    
    function Pop-Migration
    {
        Remove-Schema 'exclude'
    }
'@ | New-TestMigration -Name 'Exclude'
    
        Assert-ConvertMigration -Schemas -Exclude '*Exc*'
    
        try
        {
            Assert-Schema 'include'
            (Test-Schema 'exclude') | Should -BeFalse
        }
        finally
        {
            Pop-ConvertedScripts
        }
    }
}

Describe 'Convert-Migration.when only exporting specific migrations' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should include migrations' {
        @'
    function Push-Migration
    {
        Add-Schema 'include'
    }
    
    function Pop-Migration
    {
        Remove-Schema 'include'
    }
'@ | New-TestMigration -Name 'Include'
    
        @'
    function Push-Migration
    {
        Add-Schema 'exclude'
    }
    
    function Pop-Migration
    {
        Remove-Schema 'exclude'
    }
'@ | New-TestMigration -Name 'Exclude'
    
        Assert-ConvertMigration -Schemas -Include '*Inc*'
    
        try
        {
            Assert-Schema 'include'
            (Test-Schema 'exclude') | Should -BeFalse
        }
        finally
        {
            Pop-ConvertedScripts
        }
    }
}

Describe 'Convert-Migration.when filtering migrations before a date' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should exclude migrations before date' {
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
            (Test-Schema 'exclude') | Should -BeFalse
        }
        finally
        {
            Pop-ConvertedScripts
        }
    }
}

Describe 'Convert-Migration.when filtering migrations after a date' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should exclude migrations after date' {
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
            (Test-Schema 'exclude') | Should -BeFalse
        }
        finally
        {
            Pop-ConvertedScripts
        }
    }
}

Describe 'Convert-Migration.when a column is removed then added' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should handle removing then adding column' {
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
'@ | New-TestMigration -Name 'RemoveThenReAdd'
    
        & $convertRivetMigration -ConfigFilePath $RTConfigFilePath -OutputPath $outputDir
        $Global:Error.Count | Should -Be 0
        $sql = Get-Content -Path (Join-Path -Path $outputDir -ChildPath ('{0}.Schema.sql' -f $RTDatabaseName)) -Raw
        ($sql -notmatch 'drop column') | Should -BeTrue
    }
}

Describe 'Convert-Migration.when migrations add/remove rowguidcol' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should export correct scripts' {
        @'
function Push-Migration
{
    Add-Table 'AddMyRowGuidCol' {
        uniqueidentifier 'future_rowguidcol'
    }

    Add-Table 'RemoveMyRowGuidCol' {
        uniqueidentifier 'bye_bye_rowguidcol' -RowGuidCol
    }
}
function Pop-Migration
{
    Remove-Table 'RemoveMyRowGuidCol'
    Remove-Table 'AddMyRowGuidCol'
}
'@ | New-TestMigration -Name 'BaseTables'

        Invoke-RTRivet -Push

        @'
function Push-Migration
{
    Add-RowGuidCol -TableName 'AddMyRowGuidCol' -ColumnName  'future_rowguidcol'
    Remove-RowGuidCol -TableName 'RemoveMyRowGuidCol' -ColumnName 'bye_bye_rowguidcol'

    Add-Table 'AddInThisMigration' {
        uniqueidentifier 'add_rowguidcol'
    }

    Add-RowGuidCol -TableName 'AddInThisMigration' -ColumnName 'add_rowguidcol'

    Add-Table 'RemoveInThisMigration' {
        uniqueidentifier 'remove_rowguidcol' -RowGuidCol
    }

    Remove-RowGuidCol -TableName 'RemoveInThisMigration' -ColumnName 'remove_rowguidcol'
}
function Pop-Migration
{
    Remove-Table -Name 'RemoveInThisMigration'
    Remove-Table -Name 'AddInThisMigration'
    Remove-RowGuidCol -TableName 'AddMyRowGuidCol' -ColumnName  'future_rowguidcol'
    Add-RowGuidCol -TableName 'RemoveMyRowGuidCol' -ColumnName 'bye_bye_rowguidcol'
}
'@ | New-TestMigration -Name 'TestMe'

        Assert-ConvertMigration -Schema -Include 'TestMe'
        Assert-Column -Name 'remove_rowguidcol' -TableName 'RemoveInThisMigration' -DataType 'uniqueidentifier'
        Assert-Column -Name 'add_rowguidcol' -TableName 'AddInThisMigration' -DataType 'uniqueidentifier' -RowGuidCol
        Assert-Column -Name 'bye_bye_rowguidcol' -TableName 'RemoveMyRowGuidCol' -DataType 'uniqueidentifier'
        Assert-Column -Name 'future_rowguidcol' -TableName 'AddMyRowGuidCol' -DataType 'uniqueidentifier' -RowGuidCol
    }
}

# This one must be last!
Describe 'Convert-Migration.test fixture' {
    It 'should cover all operations' {
        $opsToSkip = @{
                        [Rivet.Operations.IrreversibleOperation] = $true;
                     }
        $missingOps = [Reflection.Assembly]::GetAssembly( [Rivet.Operation] ) |
                            ForEach-Object { $_.GetTypes() } | 
                            Where-Object { $_.IsClass } |
                            Where-Object { $_.Namespace -eq 'Rivet.Operations' } |
                            Where-Object { -not $_.IsAbstract } |
                            Where-Object { -not $testedOperations.ContainsKey( $_ ) } |
                            Where-Object { -not $opsToSkip.ContainsKey($_) } |
                            Select-Object -ExpandProperty 'Name' |
                            Sort-Object
    
        $missingOps | Should -BeNullOrEmpty
    }
}

Remove-Item -Path 'function:Watch-Operation'
