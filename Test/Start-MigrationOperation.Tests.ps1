
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:pluginErrorAction = [Management.Automation.ActionPreference]::SilentlyContinue
}

Describe 'Sample Start-MigrationOperation Plugin' {
    BeforeEach {
        Start-RivetTest -PluginPath (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\RivetSamples')
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'rejects triggers without not for replication' {
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

        { Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction $script:pluginErrorAction } | Should -Throw
        (Test-Trigger -Name 'trFoobar_Nothing') | Should -BeFalse
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[1] | Should -Match 'triggers must have "not for replication" clause'
    }

    It 'should reject big int identities' {
        $m = @'
    function Push-Migration
    {
        Add-Table Foobar -Description 'Test' {
            bigint ID -Identity -Description 'Test'
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
'@ | New-TestMigration -Name 'ValidateMigrations'

        { Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction $script:pluginErrorAction } | Should -Throw
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[1] | Should -Match 'bigint columns can''t be identity columns'
    }

    It 'should reject small int identities' {
        $m = @'
    function Push-Migration
    {
        Add-Table Foobar -Description 'Test' {
            smallint ID -Identity -Description 'Test'
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
'@ | New-TestMigration -Name 'ValidateMigrations'

        { Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction $script:pluginErrorAction } | Should -Throw
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[1] | Should -Match 'smallint columns can''t be identity columns'
    }

    It 'should reject tiny int identities' {
        $m = @'
    function Push-Migration
    {
        Add-Table Foobar -Description 'Test' {
            tinyint ID -Identity -Description 'Test'
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
'@ | New-TestMigration -Name 'ValidateMigrations'

        { Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction $script:pluginErrorAction } | Should -Throw
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[1] | Should -Match 'tinyint columns can''t be identity columns'
    }

    It 'should make identities not for replication' {
        @'
    function Push-Migration
    {
        Add-Table Foobar -Description 'Test' {
            int ID -Identity -Description 'Test'
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }
'@ | New-TestMigration -Name 'ValidateMigrations'

        Invoke-RTRivet -Push 'ValidateMigrations'

        Assert-Table 'Foobar'

        Assert-Column -TableName 'FooBar' -Name 'ID' -DataType 'int' -Seed 1 -Increment 1 -NotForReplication -NotNull
    }

    It 'should make foreign key not for replication' {
        $m = @"
    function Push-Migration
    {
        Add-Table Foo -Description 'Test' {
            int ID -Identity -Description 'Test'
        }
        Add-PrimaryKey 'Foo' 'ID'

        Add-Table Bar -Description 'Test' {
            int ID -Identity -Description 'Test'
        }
        Add-PrimaryKey 'Bar' 'ID'

        Add-ForeignKey -TableName 'Foo' -ColumnName 'ID' -References 'Bar' -ReferencedColumn 'ID'
    }

    function Pop-Migration
    {
        Remove-ForeignKey -TableName 'Foo' -Name '$(New-RTConstraintName -ForeignKey 'Foo' 'Bar')'
        Remove-Table 'Bar'
        Remove-Table 'Foo'
    }
"@ | New-TestMigration -Name 'ValidateMigrations'

        Invoke-RTRivet -Push 'ValidateMigrations'

        Assert-Table 'Foo'
        Assert-Table 'Bar'
        Assert-ForeignKey -TableName 'Foo' -References 'Bar'  -NotForReplication
    }

    It 'should make check constraints not for replication' {
       @'
    function Push-Migration
    {
        Add-Table Foo -Description 'Test' {
            varchar Name -Size '50' -NotNull -Description 'Test'
        }

        Add-CheckConstraint 'Foo' 'CK_Foo_Name' -Expression 'Name = ''Bono'' or Name = ''The Edge'''
    }

    function Pop-Migration
    {
        Remove-Table 'Foo'
    }
'@ | New-TestMigration -Name 'ValidateMigrations'

        Invoke-RTRivet -Push 'ValidateMigrations'

        Assert-Table 'Foo'
        Assert-CheckConstraint 'CK_Foo_Name' '([Name]=''Bono'' or [Name]=''The Edge'')' -NotForReplication
    }

    It 'should require description on new tables' {
       $m = @'
    function Push-Migration
    {
        Add-Table Foo {
            varchar Name -Size '50' -NotNull -Description 'Test'
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foo'
    }
'@ | New-TestMigration -Name 'ValidateMigrations'

        { Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction $script:pluginErrorAction } | Should -Throw
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[1] | Should -Match 'Table Foo''s description not found'
        (Test-Table 'Foo') | Should -BeFalse
    }

    It 'should require description on new table columns' {
       $m = @'
    function Push-Migration
    {
        Add-Table Foo -Description 'Test' {
            varchar Name -Size '50' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foo'
    }
'@ | New-TestMigration -Name 'ValidateMigrations'

        { Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction $script:pluginErrorAction } | Should -Throw
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[1] | Should -Match 'column Name''s description not found'
        (Test-Table 'Foo') | Should -BeFalse
    }

    It 'should require description on existing table new columns' {
       $m = @'
    function Push-Migration
    {
        Add-Table Foo -Description 'Test' {
            varchar Name -Size '50' -NotNull -Description 'Test'
        }

        Update-Table Foo -AddColumn {
            varchar LastName -Size 100
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foo'
    }
'@ | New-TestMigration -Name 'ValidateMigrations'

        { Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction $script:pluginErrorAction } | Should -Throw
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[1] | Should -Match 'column LastName''s description not found'
        (Test-Table 'Foo') | Should -BeFalse
    }
}
