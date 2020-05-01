
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

function GivenPlugin
{
    param(
    )

    GivenFile 'ImportRivetPluginPlugins\ImportRivetPluginPlugins.psm1' @'
    function Add-MyTable
    {
        Add-Table 'MyTable' {
            int 'ID' -Identity
        }
    }

    function Remove-MyTable
    {
        [CmdletBinding()]
        [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
        param(
            $Migration,
            $Operation
        )
        '' | Set-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath '..\pluginran')
    }
'@
}

function Init
{
    $Global:Error.Clear()
    Start-RivetTest
}

function Reset
{
    param(
        [string[]]
        $ModuleName
    )

    Stop-RivetTest -ErrorAction Ignore

    if( $ModuleName )
    {
        $ModuleName | Where-Object { Get-Module -Name $_ } | ForEach-Object { Remove-Module -Name $_ -Force }
    }
}

Describe 'Import-RivetPlugin.when plugin in a .psm1 file' {
    BeforeEach { Init }
    AfterEach { Reset -ModuleName 'ImportRivetPluginPlugins' }
    It 'should load plugins' {
        GivenPlugin
        @'
    function Push-Migration
    {
        Add-MyTable
    }
    
    function Pop-Migration
    {
        Remove-Table -Name 'MyTable'
    }
'@ | New-TestMigration -Name 'AddMyTable'

        Set-PluginPath -PluginPath 'ImportRivetPluginPlugins'
    
        Invoke-RTRivet -Push
    
        (Join-Path -Path $RTTestRoot -ChildPath 'pluginran') | Should -Exist
        Assert-Table 'MyTable'
        Get-Module -Name 'ImportRivetPluginPlugins' | Should -Not -BeNullOrEmpty
    }
}
    
Describe 'Import-RivetPlugin.when plugin is not a module' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should fail' {
        GivenFile 'Add-MyFeature.ps1' @'
    function BadPlugin
    {
    }
'@
        Set-PluginPath -PluginPath 'Add-MyFeature.ps1'
    
        @'
    function Push-Migration
    {
        Add-Table 'MyTable' {
            int 'ID' -Identity
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'MyTable'
    }
'@ | New-TestMigration -Name 'AddMyTable'
    
        Invoke-RTRivet -Push -ErrorAction SilentlyContinue
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'invalid\ plugin\ file'
    }
}

Describe 'Import-RivetPlugin.when plugin is in a module the user imports' {
    BeforeEach { Init }
    AfterEach { Reset -ModuleName 'ImportRivetPluginPlugins' }
    It 'should load plugins' {
        GivenPlugin
        @'
    function Push-Migration
    {
        Add-MyTable
    }
    
    function Pop-Migration
    {
        Remove-Table -Name 'MyTable'
    }
'@ | New-TestMigration -Name 'AddMyTable'

        Import-Module -Name (Join-Path -Path $RTTestRoot -ChildPath 'ImportRivetPluginPlugins' -Resolve)
        Mock -CommandName 'Import-Module' -ModuleName 'Rivet'

        Set-PluginPath -PluginModule 'ImportRivetPluginPlugins'
    
        Invoke-RTRivet -Push
    
        (Join-Path -Path $RTTestRoot -ChildPath 'pluginran') | Should -Exist
        Assert-Table 'MyTable'
        Get-Module -Name 'ImportRivetPluginPlugins' | Should -Not -BeNullOrEmpty
        Assert-MockCalled 'Import-Module' -ModuleName 'Rivet' -Times 0
    }
}

Describe 'Import-RivetPlugin.when plugin is in a module the user forgets to import' {
    BeforeEach { Init }
    AfterEach { Reset -ModuleName 'ImportRivetPluginPlugins' }
    It 'should load plugins' {
        GivenPlugin
        @'
    function Push-Migration
    {
        Add-MyTable
    }
    
    function Pop-Migration
    {
        Remove-Table -Name 'MyTable'
    }
'@ | New-TestMigration -Name 'AddMyTable'

        Set-PluginPath -PluginModule 'ImportRivetPluginPlugins'
    
        Invoke-RTRivet -Push -ErrorAction SilentlyContinue
    
        $Global:Error | Should -Match 'the module is not loaded'
        (Join-Path -Path $RTTestRoot -ChildPath 'pluginran') | Should -Not -Exist
        Assert-Table 'MyTable' -Not -Exists
        Get-Module -Name 'ImportRivetPluginPlugins' | Should -BeNullOrEmpty
    }
}
    
Describe 'Import-RivetPlugin.when plugin is not a module' {
    BeforeEach { Init }
    AfterEach { Reset }
    It 'should fail' {
        GivenFile 'Add-MyFeature.ps1' @'
    function BadPlugin
    {
    }
'@
        Set-PluginPath -PluginPath 'Add-MyFeature.ps1'
    
        @'
    function Push-Migration
    {
        Add-Table 'MyTable' {
            int 'ID' -Identity
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'MyTable'
    }
'@ | New-TestMigration -Name 'AddMyTable'
    
        Invoke-RTRivet -Push -ErrorAction SilentlyContinue
        $Global:Error.Count | Should -BeGreaterThan 0
    }
}
