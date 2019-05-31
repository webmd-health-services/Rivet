
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
$pluginsPath = $null

Describe 'Import-RivetPlugin' {
    BeforeEach {
        $pluginsPath = Join-Path -Path $TestDrive.FullName -ChildPath 'ImportPlugin'
        New-Item -Path $pluginsPath -ItemType 'Directory' | Out-Null
        @'
    function Add-MyTable
    {
        Add-Table 'MyTable' {
            int 'ID' -Identity
        }
    }
'@ | Set-Content -Path (Join-Path -Path $pluginsPath -ChildPath 'Add-MyTable.ps1')
    
        @'
    function Remove-MyTable
    {
        Remove-Table 'MyTable' 
    }
'@ | Set-Content -Path (Join-Path -Path $pluginsPath -ChildPath 'Remove-MyTable.ps1')
    
        Start-RivetTest -PluginPath $pluginsPath
    }
    
    AfterEach {
        Stop-RivetTest
        Remove-Item -Path $pluginsPath -Recurse
    }
    
    It 'should load plugins' {
        @'
    function Push-Migration
    {
        Add-MyTable
    }
    
    function Pop-Migration
    {
        Remove-MyTable
    }
'@ | New-TestMigration -Name 'AddMyTable'
    
        Invoke-RTRivet -Push
    
        Assert-Table 'MyTable'
    }
    
    It 'should validate plugins' {
        $badPluginPath = Join-Path -Path $pluginsPath -ChildPath 'Add-MyFeature.ps1'
        @'
    function BadPlugin
    {
    }
'@ | Set-Content -Path $badPluginPath
    
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
    
        try
        {
            Invoke-RTRivet -Push -ErrorAction SilentlyContinue
            $Global:Error.Count | Should -BeGreaterThan 0
            $Global:Error[0] | Should -Match 'not found'
        }
        finally
        {
            Remove-Item $badPluginPath
        }
    
    }
    
}
