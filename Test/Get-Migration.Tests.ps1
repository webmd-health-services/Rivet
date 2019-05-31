
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

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

Describe 'Get-Migration' {
    BeforeEach {
        $Global:Error.Clear()
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
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
        $Global:Error[0] | Should -Match 'Migration ''nomigrationbythisname'' not found\.'
    }
    
    It 'should not write an error if included wildcarded migration not found' {
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Include '*fubar*'
        $result | Should -BeNullOrEmpty
        $Global:Error.Count | Should -Be 0
    }
    
    It 'should include migration by name or i d' {
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
    
    It 'should include migration wildcard i d' {
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
    
    It 'should exclude migration by name or i d' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }
    
    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'ShouldExcludeMigrationByNameOrID'
    
    
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude 'ShouldExcludeMigrationByNameOrID'
        $Global:Error.Count | Should -Be 0
        $result | Should -BeNullOrEmpty
    
        $id = ($m.BaseName -split '_')[0]
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude $id
        $Global:Error.Count | Should -Be 0
        $result | Should -BeNullOrEmpty
    }
    
    It 'should exclude migration wildcard i d' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }
    
    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'ShouldExcludeMigrationWildcardID'
    
        $id = ($m.BaseName -split '_')[0]
    
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude ('{0}*' -f $id.Substring(0,10))
        $Global:Error.Count | Should -Be 0
        $result | Should -BeNullOrEmpty
    }
    
    It 'should exclude a migration by base name' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }
    
    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'ShouldExcludeAMigrationByBaseName'
    
        $id = ($m.BaseName -split '_')[0]
    
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude $m.BaseName
        $Global:Error.Count | Should -Be 0
        $result | Should -BeNullOrEmpty
    }
    
    It 'should exclude a migration by base name with wildcard' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }
    
    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | New-TestMigration -Name 'ShouldExcludeAMigrationByBaseNameWithWildcard'
    
        $id = ($m.BaseName -split '_')[0]
    
        $result = Get-Migration -ConfigFilePath $RTConfigFilePath -Exclude ('{0}*' -f $m.BaseName.Substring(0,20))
        $Global:Error.Count | Should -Be 0
        $result | Should -BeNullOrEmpty
    }    
}
