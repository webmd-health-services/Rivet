
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:pluginErrorAction = [Management.Automation.ActionPreference]::SilentlyContinue
}

Describe 'Invoke-MigrationOperation' {
    BeforeEach {
        Start-RivetTest -PluginPath (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\RivetSamples')
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'runs plugins' {
        @'
    function Push-Migration
    {
        Add-Schema 'fubar'
        Add-Table -SchemaName 'fubar' Foobar -Description 'Test' {
            BigInt ID -Description 'Test'
        }
    }

    function Pop-Migration
    {
        Remove-Table -SchemaName 'fubar' 'Foobar'
        Remove-Schema 'fubar'
    }

'@ | New-TestMigration -Name 'CompleteAdminPlugin'

        Invoke-RTRivet -Push 'CompleteAdminPlugin'

        Assert-Column -Name CreateDate -DataType smalldatetime -NotNull -TableName "Foobar" -SchemaName 'fubar'
        Assert-Column -Name LastUpdated -DataType datetime -NotNull -TableName "Foobar" -SchemaName 'fubar'
        Assert-Column -Name RowGuid -DataType uniqueidentifier -NotNull -RowGuidCol -TableName "Foobar" -SchemaName 'fubar'
        Assert-Column -Name SkipBit -DataType bit -TableName "Foobar" -SchemaName 'fubar'
        Assert-Index -TableName 'Foobar' -ColumnName 'rowguid' -Unique -SchemaName 'fubar'
        Assert-DefaultConstraint -SchemaName 'fubar' `
                                 -TableName 'Foobar' `
                                 -ColumnName 'rowguid' `
                                 -Name 'DF_fubar_Foobar_rowguid'
        Assert-Trigger -Name 'trFoobar_Activity' -SchemaName 'fubar'
    }

    It 'plugins should skip row guid' {
        @'
    function Push-Migration
    {
        Add-Table Foobar -Description 'Test' {
            uniqueidentifier guid -RowGuidCol -Description 'Test'
        }
    }

    function Pop-Migration
    {
        Remove-Table Foobar
    }
'@ | New-TestMigration -Name 'SkipRowGuid'

        Invoke-RTRivet -Push 'SkipRowGuid'

        Assert-Column -Name guid -DataType uniqueidentifier -RowGuidCol -TableName "Foobar"
        (Test-Column -TableName 'Foobar' -Name 'rowguid') | Should -BeFalse
    }

    It 'plugins can fail migration' {
        $m = @'
    function Push-Migration
    {
        Add-Table Foobar -Description 'Test' {
            int ID -Identity -Description 'Test'
        }

        $trigger = @"
    ON [dbo].[Foobar]
    FOR UPDATE
    AS
        RETURN
"@

        Add-Trigger 'trFoobar_Nothing' -Definition $trigger
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
'@ | New-TestMigration -Name 'ValidateMigrations'

        { Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction $script:pluginErrorAction } |
            Should -Throw '*errors running "AddTriggerOperation"*' #
        (Test-Trigger -Name 'trFoobar_Nothing') | Should -BeFalse
        $Global:Error.Count | Should -BeGreaterThan 0
    }
}
