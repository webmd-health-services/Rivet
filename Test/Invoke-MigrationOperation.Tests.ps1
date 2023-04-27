
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Invoke-MigrationOperation' {
    BeforeEach {
        Start-RivetTest -PluginPath (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\RivetSamples')
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should run plugins' {
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

    It 'should reject triggers without not for replication' {
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

        try
        {
            Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction SilentlyContinue
            (Test-Trigger -Name 'trFoobar_Nothing') | Should -BeFalse
            $Global:Error.Count | Should -BeGreaterThan 0
        }
        finally
        {
            Remove-Item $m
        }
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

        try
        {
            Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction SilentlyContinue
            $Global:Error.Count | Should -BeGreaterThan 0
        }
        finally
        {
            Remove-Item $m
        }
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

        try
        {
            Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction SilentlyContinue
            $Global:Error.Count | Should -BeGreaterThan 0
        }
        finally
        {
            Remove-Item $m
        }
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

        try
        {
            Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction SilentlyContinue
            $Global:Error.Count | Should -BeGreaterThan 0
        }
        finally
        {
            Remove-Item $m
        }
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

        try
        {
            Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction SilentlyContinue

            $Global:Error.Count | Should -BeGreaterThan 0

            (Test-Table 'Foo') | Should -BeFalse
        }
        finally
        {
            Remove-Item $m
        }
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

        try
        {
            Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction SilentlyContinue

            $Global:Error.Count | Should -BeGreaterThan 0

            (Test-Table 'Foo') | Should -BeFalse
        }
        finally
        {
            Remove-Item $m
        }
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

        try
        {
            Invoke-RTRivet -Push 'ValidateMigrations' -ErrorAction SilentlyContinue

            $Global:Error.Count | Should -BeGreaterThan 0

            (Test-Table 'Foo') | Should -BeFalse
        }
        finally
        {
            Remove-Item $m
        }
    }
}
