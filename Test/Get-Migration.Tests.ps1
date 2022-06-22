
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

$pluginModuleName = 'GetMigrationPlugins'
$pluginModulePath = '{0}\{0}.psm1' -f $pluginModuleName
$migrations = $null

$noOpMigration = @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}

function Pop-Migration
{
    Invoke-Ddl 'select 1'
}
'@

function Assert-GetMigration
{
    param(
        [Rivet.Migration]
        $m
    )
    
    Set-StrictMode -Version 'Latest'
    $Global:Error.Count | Should -Be 0
    $m | Should -Not -BeNullOrEmpty
    $m | Should -BeOfType ([Rivet.Migration])
    $m.Name | Should -Be 'ShouldGetMigrationsUsingCurrentRivetJsonFile'
    
    $m.PushOperations.Count | Should -Be 1
    $pushOp = $m.PushOperations[0]
    $pushOp | Should -BeOfType ([Rivet.Operations.AddSchemaOperation])
    $pushOp.Name | Should -Be 'ShouldGetMigrationsUsingCurrentRivetJsonFile'
    
    $m.PopOperations.Count | Should -Be 1
    $popOp = $m.PopOperations[0]
    $popOp | Should -BeOfType ([Rivet.Operations.RemoveSchemaOperation])
    $popOp.Name | Should -Be 'ShouldGetMigrationsUsingCurrentRivetJsonFile'
    
}

function Init
{
    param(
        [switch]$WithPlugin
    )

    $Global:Error.Clear()

    $conditionalParams = @{}
    if( $WithPlugin )
    {
        $conditionalParams['PluginPath'] = $pluginModuleName
    }
    Start-RivetTest @conditionalParams
}

function Reset
{
    Stop-RivetTest
    if( (Get-Module $pluginModuleName) )
    {
        Remove-Module $pluginModuleName
    }
}

function WhenGettingMigrations
{
    [CmdletBinding()]
    param(
    )

    $script:migrations = Get-Migration -ConfigFilePath $RTConfigFilePath
}

Describe 'Get-Migration' {
    BeforeEach { Init }
    AfterEach { Reset }
    
    It 'should get migrations using current rivet json file' {
        New-Item -Path (Join-Path -Path $TestDrive.FullName -ChildPath ('Databases\{0}\Migrations' -f $RTDatabaseName)) -ItemType 'Directory' -Force
    
        $rivetJsonPath = Join-Path -Path $TestDrive -ChildPath 'rivet.json'
        (@'
        {{
            DatabasesRoot: 'Databases',
            SqlServerName: {0}
        }}
'@ -f ($RTServer.ToString() | ConvertTo-Json)) | Set-Content -Path $rivetJsonPath
    
        @'
        function Push-Migration
        {
            Add-Schema 'ShouldGetMigrationsUsingCurrentRivetJsonFile'
        }
    
        function Pop-Migration
        {
            Remove-Schema 'ShouldGetMigrationsUsingCurrentRivetJsonFile'
        }
'@ | New-TestMigration -Name 'ShouldGetMigrationsUsingCurrentRivetJsonFile' -ConfigFilePath $rivetJsonPath | Format-Table | Out-String | Write-Verbose
    
        Push-Location -Path $TestDrive -StackName $PSCommandPath
        try
        {
            Assert-GetMigration (Get-Migration)
            Assert-GetMigration (Get-Migration -Database $RTDatabaseName  -ConfigFilePath $rivetJsonPath)
            $Global:Error.Count | Should -Be 0
        }
        finally
        {
            Pop-Location -StackName $PSCommandPath
        }
    
        # Now, use an explicit path.
        Assert-GetMigration (Get-Migration -ConfigFilePath $rivetJsonPath)
    }
    
    It 'should protect against items returned from pipeline' {
        @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }
    1 # See that guy? We should protect ourselves against shit like that.
    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'ShouldProtectAgainstItemsReturnedFromPipeline'
    
        $m = Get-Migration -ConfigFilePath $RTConfigFilePath
        $Global:Error.Count | Should -Be 0
        $m | Should -BeOfType ([Rivet.Migration])
    }
    
    It 'should reject migration with empty push' {
        $m = @'
    function Push-Migration
    {
        # I'm empty. That is bad!
    }
    
    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'EmptyPush'
    
        try
        {
            $result = Get-Migration -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
            $result | Should -BeNullOrEmpty
            $Global:Error.Count | Should -BeGreaterThan 0
            $Global:Error[0] | Should -Match 'Push-Migration.*empty'
        }
        finally
        {
            Remove-Item -Path $m.FullName
        }
    }
    
    It 'should reject migration with empty pop' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }
    
    function Pop-Migration
    {
        # I'm empty. That is bad!
    }
'@ | New-TestMigration -Name 'EmptyPop'
    
        try
        {
            $result = Get-Migration -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
            $result | Should -BeNullOrEmpty
            $Global:Error.Count | Should -BeGreaterThan 0
            $Global:Error[0] | Should -Match 'Pop-Migration.*empty'
        }
        finally
        {
            Remove-Item -Path $m.FullName
        }
    }
    
    It 'should reject migration with no push migration function' {
        $m = @'
    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'MissingPush'
    
        try
        {
            $result = Get-Migration -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
            $result | Should -BeNullOrEmpty
            $Global:Error.Count | Should -BeGreaterThan 0
            $Global:Error[0] | Should -Match 'Push-Migration.*not found'
        }
        finally
        {
            Remove-Item -Path $m.FullName
        }
    }
    
    It 'should reject migration with no pop migration function' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'MissingPop'
    
        try
        {
            $result = Get-Migration -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
            $result | Should -BeNullOrEmpty
            $Global:Error.Count | Should -BeGreaterThan 0
            $Global:Error[0] | Should -Match 'Pop-Migration.*not found'
        }
        finally
        {
            Remove-Item -Path $m.FullName
        }
    }
    
    It 'should write an error if included migration not found' {
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include 'nomigrationbythisname' -ErrorAction SilentlyContinue
        $result | Should -BeNullOrEmpty
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'Migration "nomigrationbythisname" not found\.'
    }
    
    It 'should not write an error if included wildcarded migration not found' {
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include '*fubar*'
        $result | Should -BeNullOrEmpty
        $Global:Error.Count | Should -Be 0
    }
    
    It 'should include migration by name or ID' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }
    
    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'ShouldIncludeMigrationByNameOrID'
    
        $id = ($m.BaseName -split '_')[0]
    
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include 'ShouldIncludeMigrationByNameOrID'
        $result | Should -Not -BeNullOrEmpty
        $id | Should -Be $result.ID
        'ShouldIncludeMigrationByNameOrID' | Should -Be $result.Name
        $m.BaseName | Should -Be $result.FullName
    
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include $id
        $result | Should -Not -BeNullOrEmpty
        $id | Should -Be $result.ID
        'ShouldIncludeMigrationByNameOrID' | Should -Be $result.Name
        $m.BaseName | Should -Be $result.FullName
    }
    
    It 'should include migration wildcard ID' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }
    
    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'ShouldIncludeMigrationWildcardID'
    
        $id = ($m.BaseName -split '_')[0]
    
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include ('{0}*' -f $id.Substring(0,10))
        $result | Should -Not -BeNullOrEmpty
        $id | Should -Be $result.ID
        'ShouldIncludeMigrationWildcardID' | Should -Be $result.Name
        $m.BaseName | Should -Be $result.FullName
    }
    
    It 'should get a migration by base name' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }
    
    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'ShouldGetAMigrationByBaseName'
    
        $id = ($m.BaseName -split '_')[0]
    
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include $m.BaseName
        $result | Should -Not -BeNullOrEmpty
        $id | Should -Be $result.ID
        'ShouldGetAMigrationByBaseName' | Should -Be $result.Name
        $m.BaseName | Should -Be $result.FullName
    }
    
    It 'should get a migration by base name with wildcard' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }
    
    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'ShouldGetAMigrationByBaseNameWithWildcard'
    
        $id = ($m.BaseName -split '_')[0]
    
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include ('{0}*' -f $m.BaseName.Substring(0,20))
        $result | Should -Not -BeNullOrEmpty
        $id | Should -Be $result.ID
        'ShouldGetAMigrationByBaseNameWithWildcard' | Should -Be $result.Name
        $m.BaseName | Should -Be $result.FullName
    }
}

Describe 'Get-Migration.when excluding migrations' {
    AfterEach { Reset }
    It 'should match against ID, name, and base name and support wildcards' {
        Init
        $m = $noOpMigration | New-TestMigration -Name 'ShouldExcludeMigrationByNameOrID'
        $id = ($m.BaseName -split '_')[0]

        $noOpMigration | New-TestMigration -Name 'ShouldInclude'
        $noOpMigration | New-TestMigration -Name 'ShouldExcludeIfUsingWildcards'
    
        # When excluding a specific migration by name.
        Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude 'ShouldExcludeMigrationByNameOrID' | Should -HaveCount 2
        Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude 'ShouldExclude*'  | Should -HaveCount 1

        # Should match against base name.
        Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude $m.BaseName | Should -HaveCount 2
        Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude "$($id.Substring(0, 4))*_ShouldExcludeMig*" | Should -HaveCount 2
    
        # Should match against ID.
        Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude $id | Should -HaveCount 2
        Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude "$($id.Substring(0, 4))*" | Should -BeNullOrEmpty

        # should match multiple exclude patterns
        Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude '*Wildcards','*ID' | Should -HaveCount 1

        $Global:Error | Should -BeNullOrEmpty
    }
}

Describe 'Get-Migration.when there is a BeforeOperationLoad plugin' {
    BeforeEach { Init -WithPlugin }
    AfterEach { Reset }
    It ('should run the plugin') {
        GivenFile $pluginModulePath @'
function OnAdd
{
    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
    param(
        $Migration,
        $Operation
    )

    Add-Schema 'boom'
}
'@
        @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}
function Pop-Migration
{
    Invoke-Ddl 'select 2'
}
'@ | New-TestMigration -Name 'One'
        WhenGettingMigrations
        $migrations | Should -Not -BeNullOrEmpty
        $migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
        $migrations.PushOperations[1] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
        $migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
        $migrations.PopOperations[1] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
    }
}

Describe 'Get-Migration.when there are multiple BeforeOperationLoad plugins' {
    BeforeEach { Init -WithPlugin }
    AfterEach { Reset }
    It ('should run all the plugins') {
        GivenFile $pluginModulePath @'
function OnAdd
{
    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
    param(
        $Migration,
        $Operation
    )

    Add-Schema 'boom'
}

function AnotherOnAdd
{
    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
    param(
        $Migration,
        $Operation
    )

    Add-Schema 'boom'
}
'@
        @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}
function Pop-Migration
{
    Invoke-Ddl 'select 2'
}
'@ | New-TestMigration -Name 'One'
        WhenGettingMigrations
        $migrations | Should -Not -BeNullOrEmpty
        $migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
        $migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
    }
}

Describe 'Get-Migration.when BeforeOperationLoad plugin missing Migration parameter' {
    BeforeEach { Init -WithPlugin }
    AfterEach { Reset }
    It ('should fail') {
        GivenFile $pluginModulePath @'
function OnAdd
{
    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
    param(
        $Operation
    )

    Add-Schema -Name 'Fubar'
}
'@
        @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}
function Pop-Migration
{
    Invoke-Ddl 'select 2'
}
'@ | New-TestMigration -Name 'One'
        WhenGettingMigrations -ErrorAction SilentlyContinue
        $migrations | Should -BeNullOrEmpty
        $Global:Error | Should -Match '"BeforeOperationLoad"\ event\ must\ have\ a\ named\ "Migration"\ parameter'
    }
}


Describe 'Get-Migration.when BeforeOperationLoad plugin missing Operation parameter' {
    BeforeEach { Init -WithPlugin }
    AfterEach { Reset }
    It ('should fail') {
        GivenFile $pluginModulePath @'
function OnAdd
{
    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
    param(
        $Migration
    )

    Add-Schema -Name 'Fubar'
}
'@
        @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}
function Pop-Migration
{
    Invoke-Ddl 'select 2'
}
'@ | New-TestMigration -Name 'One'
        WhenGettingMigrations -ErrorAction SilentlyContinue
        $migrations | Should -BeNullOrEmpty
        $Global:Error | Should -Match '"BeforeOperationLoad"\ event\ must\ have\ a\ named\ "Operation"\ parameter'
    }
}

Describe 'Get-Migration.when there is an AfterOperationLoad plugin' {
    BeforeEach { Init -WithPlugin }
    AfterEach { Reset }
    It ('should run the plugin') {
        GivenFile $pluginModulePath @'
function OnAdd
{
    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
    param(
        $Migration,
        $Operation
    )

    Add-Schema 'boom'
}
'@
        @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}
function Pop-Migration
{
    Invoke-Ddl 'select 2'
}
'@ | New-TestMigration -Name 'One'
        WhenGettingMigrations
        $migrations | Should -Not -BeNullOrEmpty
        $migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
        $migrations.PushOperations[0] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
        $migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
        $migrations.PopOperations[0] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
    }
}

Describe 'Get-Migration.when there are multiple AfterOperationLoad plugins' {
    BeforeEach { Init -WithPlugin }
    AfterEach { Reset }
    It ('should run all the plugins') {
        GivenFile $pluginModulePath @'
function OnAdd
{
    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
    param(
        $Migration,
        $Operation
    )

    Add-Schema 'boom'
}

function AnotherOnAdd
{
    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
    param(
        $Migration,
        $Operation
    )

    Add-Schema 'boom'
}
'@
        @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}
function Pop-Migration
{
    Invoke-Ddl 'select 2'
}
'@ | New-TestMigration -Name 'One'
        WhenGettingMigrations
        $migrations | Should -Not -BeNullOrEmpty
        $migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
        $migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
    }
}

Describe 'Get-Migration.when AfterOperationLoad plugin missing Migration parameter' {
    BeforeEach { Init -WithPlugin }
    AfterEach { Reset }
    It ('should fail') {
        GivenFile $pluginModulePath @'
function OnAdd
{
    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
    param(
        $Operation
    )

    Add-Schema -Name 'Fubar'
}
'@
        @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}
function Pop-Migration
{
    Invoke-Ddl 'select 2'
}
'@ | New-TestMigration -Name 'One'
        WhenGettingMigrations -ErrorAction SilentlyContinue
        $migrations | Should -BeNullOrEmpty
        $Global:Error | Should -Match '"AfterOperationLoad"\ event\ must\ have\ a\ named\ "Migration"\ parameter'
    }
}


Describe 'Get-Migration.when AfterOperationLoad plugin missing Operation parameter' {
    BeforeEach { Init -WithPlugin }
    AfterEach { Reset }
    It ('should fail') {
        GivenFile $pluginModulePath @'
function OnAdd
{
    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
    param(
        $Migration
    )

    Add-Schema -Name 'Fubar'
}
'@
        @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}
function Pop-Migration
{
    Invoke-Ddl 'select 2'
}
'@ | New-TestMigration -Name 'One'
        WhenGettingMigrations -ErrorAction SilentlyContinue
        $migrations | Should -BeNullOrEmpty
        $Global:Error | Should -Match '"AfterOperationLoad"\ event\ must\ have\ a\ named\ "Operation"\ parameter'
    }
}

Describe 'Get-Migration.when a plugin returns a non-operation' {
    BeforeEach { Init -WithPlugin }
    AfterEach { Reset }
    It ('should run the plugin') {
        GivenFile $pluginModulePath @'
function OnAdd
{
    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
    param(
        $Migration,
        $Operation
    )

    1
}
'@
        @'
function Push-Migration
{
    Invoke-Ddl 'select 1'
}
function Pop-Migration
{
    Invoke-Ddl 'select 2'
}
'@ | New-TestMigration -Name 'One'
        WhenGettingMigrations
        $migrations | Should -Not -BeNullOrEmpty
        $migrations.PushOperations | Should -BeOfType ([Rivet.Operations.Operation])
        $migrations.PopOperations | Should -BeOfType ([Rivet.Operations.Operation])
    }
}
