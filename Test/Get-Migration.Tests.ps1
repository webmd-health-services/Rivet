
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:pluginModuleName = 'GetMigrationPlugins'
    $script:pluginModulePath = '{0}\{0}.psm1' -f $script:pluginModuleName
    $script:migrations = $null

    $script:noOpMigration = @'
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
            [hashtable] $StartArgument = @{}
        )
        $Global:Error.Clear()
        Start-RivetTest @StartArgument
        $script:migrations = @()
    }

    function Reset
    {
        Stop-RivetTest
    }

    function WhenGettingMigrations
    {
        [CmdletBinding()]
        param(
        )

        $script:migrations = Get-Migration -ConfigFilePath $RTConfigFilePath
    }
}

Describe 'Get-Migration' {
    BeforeEach {
        Init
    }

    AfterEach {
        Reset
    }

    It 'should get migrations using current rivet json file' {
        New-Item -Path (Join-Path -Path $TestDrive -ChildPath ('Databases\{0}\Migrations' -f $RTDatabaseName)) -ItemType 'Directory' -Force

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

    It 'should ignore migration with empty push' {
        $m = @'
    function Push-Migration
    {
        # I'm empty.
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
            $Global:Error | Should -BeNullOrEmpty
        }
        finally
        {
            Remove-Item -Path $m.FullName
        }
    }

    It 'should ignore migration with empty pop' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }

    function Pop-Migration
    {
        # I'm empty.
    }
'@ | New-TestMigration -Name 'EmptyPop'

        try
        {
            $result = Get-Migration -ConfigFilePath $RTConfigFilePath -ErrorAction SilentlyContinue
            $result | Should -BeNullOrEmpty
            $Global:Error | Should -BeNullOrEmpty
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
            $result =
                { Get-Migration -ConfigFilePath $RTConfigFilePath } |
                Should -Throw '*Push-Migration function not found*'
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
            $result =
                { Get-Migration -ConfigFilePath $RTConfigFilePath } |
                Should -Throw '*Pop-Migration function not found*'
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

    It 'should set timeout duration to default 30 seconds on Rivet operations when CommandTimeout isn''t specified in the Rivet configuration' {
        @'
        function Push-Migration
        {
            Invoke-Ddl 'select 1'
        }
        function Pop-Migration
        {
            Invoke-Ddl 'select 1'
        }
'@ | New-TestMigration -Name 'SetCommandTimeout'

        $m = Get-Migration -ConfigFilePath $RTConfigFilePath
        $Global:Error.Count | Should -Be 0
        $m | Should -BeOfType ([Rivet.Migration])
        $m.PopOperations[0].CommandTimeout | Should -Be 30
        $m.PushOperations[0].CommandTimeout | Should -Be 30
    }

    It 'should set timeout duration on Rivet operations when CommandTimeout is specified in the Rivet configuration' {
        Start-RivetTest -CommandTimeout 60
        @'
        function Push-Migration
        {
            Invoke-Ddl 'select 1'
        }
        function Pop-Migration
        {
            Invoke-Ddl 'select 1'
        }
'@ | New-TestMigration -Name 'SetCommandTimeout'

        $m = Get-Migration -ConfigFilePath $RTConfigFilePath
        $Global:Error.Count | Should -Be 0
        $m | Should -BeOfType ([Rivet.Migration])
        $m.PopOperations[0].CommandTimeout | Should -Be 60
        $m.PushOperations[0].CommandTimeout | Should -Be 60
    }

    It 'should match exclude pattern against ID, name, and base name and support wildcards' {
        $m = $script:noOpMigration | New-TestMigration -Name 'ShouldExcludeMigrationByNameOrID'
        $id = ($m.BaseName -split '_')[0]

        $script:noOpMigration | New-TestMigration -Name 'ShouldInclude'
        $script:noOpMigration | New-TestMigration -Name 'ShouldExcludeIfUsingWildcards'

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

Describe 'Get-Migration' {
    BeforeEach {
        Init -StartArgument @{ PluginPath = $script:pluginModuleName }
    }

    AfterEach {
        Reset
        if ((Get-Module $script:pluginModuleName))
        {
            Remove-Module $script:pluginModuleName
        }
    }

    It ('should run the plugin') {
        GivenFile $script:pluginModulePath @'
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
        $script:migrations | Should -Not -BeNullOrEmpty
        $script:migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
        $script:migrations.PushOperations[1] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
        $script:migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
        $script:migrations.PopOperations[1] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
    }

    It ('should run all the plugins') {
        GivenFile $script:pluginModulePath @'
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
        $script:migrations | Should -Not -BeNullOrEmpty
        $script:migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
        $script:migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
    }

    It 'runs before operation load plugins' {
        GivenFile $script:pluginModulePath @'
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
        { WhenGettingMigrations } |
            Should -Throw '*"BeforeOperationLoad" event must have a named "Migration" parameter*'
        $script:migrations | Should -BeNullOrEmpty
    }

    It ('should fail') {
        GivenFile $script:pluginModulePath @'
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
        { WhenGettingMigrations } |
            Should -Throw '*"BeforeOperationLoad" event must have a named "Operation" parameter*'
        $script:migrations | Should -BeNullOrEmpty
    }

    It ('should run the plugin') {
        GivenFile $script:pluginModulePath @'
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
        $script:migrations | Should -Not -BeNullOrEmpty
        $script:migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
        $script:migrations.PushOperations[0] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
        $script:migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
        $script:migrations.PopOperations[0] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
    }

    It ('should run all the plugins') {
        GivenFile $script:pluginModulePath @'
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
        $script:migrations | Should -Not -BeNullOrEmpty
        $script:migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
        $script:migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
    }

    It ('should fail') {
        GivenFile $script:pluginModulePath @'
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
        { WhenGettingMigrations } | Should -Throw '*"AfterOperationLoad" event must have a named "Migration" parameter*'
        $script:migrations | Should -BeNullOrEmpty
    }

    It ('should fail') {
        GivenFile $script:pluginModulePath @'
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
        { WhenGettingMigrations } | Should -Throw '*"AfterOperationLoad" event must have a named "Operation" parameter*'
        $script:migrations | Should -BeNullOrEmpty
        $Global:Error | Should -Match
    }

    It ('should run the plugin') {
        GivenFile $script:pluginModulePath @'
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
        $script:migrations | Should -Not -BeNullOrEmpty
        $script:migrations.PushOperations | Should -BeOfType ([Rivet.Operations.Operation])
        $script:migrations.PopOperations | Should -BeOfType ([Rivet.Operations.Operation])
    }

    It ('should run the plugin when an AddSchemaOperation exists') {
        GivenFile $script:pluginModulePath @'
function OnAdd
{
    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
    param(
        $Migration,
        $Operation
    )

    Add-Schema 'boom'
}

function AfterMigration
{

    [Rivet.Plugin([Rivet.Events]::AfterMigrationLoad)]
    param(
        $Migration
    )

    $addSchemaOperation = $Migration.PushOperations | Where-Object{ $_ -is [Rivet.Operations.AddSchemaOperation]}

    if( -not $addSchemaOperation )
    {
        Write-Error 'Please add a schema!'
    }
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
        $script:migrations | Should -Not -BeNullOrEmpty
        $script:migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
        $script:migrations.PushOperations[1] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
        $script:migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
        $script:migrations.PopOperations[1] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
    }

    It ('should throw an error when AddSchemaOperation doesn''t exist') {
        GivenFile $script:pluginModulePath @'
function AfterMigration
{

    [Rivet.Plugin([Rivet.Events]::AfterMigrationLoad)]
    param(
        $Migration
    )

    $problems = $false
    $addSchemaOperation = $Migration.PushOperations | Where-Object{ $_ -is [Rivet.Operations.AddSchemaOperation]}

    if( -not $addSchemaOperation )
    {
        throw ('Please add a schema!')
    }
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
        { WhenGettingMigrations } | Should -Throw '*Please add a schema!*'
        $script:migrations | Should -BeNullOrEmpty
    }
}