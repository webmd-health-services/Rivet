
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

function GivenFile
{
    param(
        $Path,
        $Content
    )

    $Path = Join-Path -Path $TestDrive.FullName -ChildPath $Path
    $parentPath = $Path | Split-Path
    if( -not (Test-Path -Path $parentPath -PathType Container) )
    {
        New-Item -Path $parentPath -ItemType 'Directory'
    }

    @'
    function Add-MyTable
    {
        Add-Table 'MyTable' {
            int 'ID' -Identity
        }
    }

    function Remove-MyTable
    {
        [CmdletBinding()]
        [Rivet.Plugin([Rivet.Events]::BeforePluginAdd)]
        param(
            $Migration,
            $Operation
        )
        New-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath '..\pluginran')
    }
'@ | Set-Content -Path $Path
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
    
        (Join-Path -Path $TestDrive.FullName -ChildPath 'pluginran') | Should -Exist
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
