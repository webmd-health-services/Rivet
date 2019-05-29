
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

$pluginsRoot = $null

Describe 'Update-Database' {
    BeforeEach {
        $Global:Error.Clear()
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
        if( $pluginsRoot -and (Test-Path -Path $pluginsRoot -PathType Container) )
        {
            $pluginsRoot | Remove-Item -Recurse
        }
    }
    
    It 'should allow long migration names' {
        $migrationPathLength = $RTDatabaseMigrationRoot.Length
        # remove length of the separator, timestamp, underscore and extension
        $name = 'a' * (259 - $migrationPathLength - 1 - 14 - 1 - 4)
    
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            BigInt ID
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
    
'@ | New-TestMigration -Name $name
    
        Invoke-RTRivet -Push
        $Global:Error.Count | Should -Be 0
        (Test-Table 'Foobar') | Should -Be $true
    }
    
    It 'should not run plugins on already applied migrations' {
        @'
    function Push-Migration
    {
        Add-Table 'ShouldNotValidateAlreadyAppliedMigrations' {
            int 'ID'
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'ShouldNotValidateAlreadyAppliedMigrations'
    }
'@ | New-TestMigration -Name 'Original'
    
        Invoke-RTRivet -Push
    
        $pluginsRoot = New-PluginsRoot -Prefix $PSCommandPath
    
        $startMigrationOperationPath = Join-Path -Path $pluginsRoot -ChildPath 'Start-MigrationOperation.ps1'
        @'
    function Start-MigrationOperation
    {
        [CmdletBinding()]
        param(
            $Migration,
            $Operation
        )
    
        Set-StrictMode -Version 'Latest'
    
        if( $Operation -is [Rivet.Operations.AddTableOperation] )
        {
            throw 'BOOM!'
        }
    }
'@ | Set-Content -Path $startMigrationOperationPath
    
        try
        {
            @'
    function Push-Migration
    {
        Add-Schema 'ShouldNotValidateAlreadyAppliedMigrations'
    }
    
    function Pop-Migration
    {
        Remove-Schema 'ShouldNotValidateAlreadyAppliedMigrations'
    }
'@ | New-TestMigration -Name 'Second'
    
            Invoke-RTRivet -Push
            $Global:Error.Count | Should -Be 0
            Assert-Schema 'ShouldNotValidateAlreadyAppliedMigrations'
        }
        finally
        {
            Remove-Item -Path $startMigrationOperationPath
        }
    }
}
