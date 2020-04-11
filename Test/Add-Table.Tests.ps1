
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'Add-Table' {
    BeforeEach {
        Start-RivetTest
        $Global:Error.Clear()
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should create table' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'AddTable' -Description 'Testing Add-Table migration' -Column {
            VarChar 'varchar' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
            BigInt 'id' -Identity
        } -Option 'data_compression = none'
    
        # Sql 2012 feature
        # Add-Table 'FileTable' -FileTable
    }
    
    function Pop-Migration()
    {
        Remove-Table 'AddTable'
    }
'@ | New-TestMigration -Name 'CreateTable'
        Invoke-RTRivet -Push 'CreateTable'
    
        Assert-Table 'AddTable' -Description 'Testing Add-Table migration'
        Assert-Column -Name 'varchar' 'varchar' -NotNull -Description 'varchar(max) constraint DF_AddTable_varchar default default' -TableName 'AddTable'
        Assert-Column -Name 'id' 'bigint' -NotNull -Seed 1 -Increment 1 -TableName 'AddTable'
    
        # Sql 2012 feature
        # Assert-Table 'FileTable'
        # Assert-Column -TableName 'FileTable' -Name  'path_locator' 'hierarchyid'
    }
    
    It 'should create table in custom schema' {
        @'
    function Push-Migration()
    {
        Add-Schema 'rivettest'
        Add-Table 'AddTableInRivetTest' {
            Int 'id' -Identity -Description 'AddTableInRivetTest identity column'
        } -SchemaName 'rivettest' -Description 'Testing Add-Table migration for custom schema.' 
    
        # Sql 2012 feature
        # Add-Table 'FileTable' -FileTable
    }
    
    function Pop-Migration()
    {
        Remove-Table 'AddTableInRivetTest' -SchemaName 'rivettest'
        Remove-Schema 'rivettest'
    }
'@ | New-TestMigration -Name 'CreateTableInCustomSchema'
    
        Invoke-RTRivet -Push 'CreateTableInCustomSchema'
    
        Assert-Table 'AddTableInRivetTest' -SchemaName 'rivettest' -Description 'Testing Add-Table migration for custom schema.'
        Assert-Column -Name 'id' 'int' -NotNull -Seed 1 -Increment 1 -Description 'AddTableInRivetTest identity column' -TableName 'AddTableInRivetTest' -SchemaName 'rivettest'
    }
    
    It 'should create with custom file group' {
        @'
    function Push-Migration()
    {
        Add-Table 'CustomFileGroup' {
            Int 'id' -Identity
        } -FileGroup '"rivet"' 
    }
    
    function Pop-Migration()
    {
        Remove-Table 'CustomFileGroup'
    }
'@ | New-TestMigration -Name 'CreateTableWithCustomFileGroup'
    
        Invoke-RTRivet -Push 'CreateTableWithCustomFileGroup' -ErrorAction SilentlyContinue
        $Global:Error.Count | Should -BeGreaterThan 0
        (Test-Table -Name 'CustomFileGroup') | Should -BeFalse
    }
    
    It 'should create with custom text image file group' {
        @'
    function Push-Migration()
    {
        Add-Table 'CustomTextImageFileGroup' {
            Int 'id' -Identity
        } -TextImageFileGroup '"rivet"' 
    }
    
    function Pop-Migration()
    {
        Remove-Table 'CustomTextImageFileGroup'
    }
'@ | New-TestMigration -Name 'CreateTableWithCustomTextImageFileGroup'
    
        Invoke-RTRivet -Push 'CreateTableWithCustomTextImageFileGroup' -ErrorAction SilentlyContinue
        $Global:Error.Count | Should -BeGreaterThan 0
        (Test-Table -Name 'CustomTextImageFileGroup') | Should -BeFalse
    }
    
    It 'should create with custom file stream file group' {
        @'
    function Push-Migration()
    {
        Add-Table 'CustomTextImageFileGroup' {
            Int 'id' -Identity
        } -FileStreamFileGroup '"rivet"' 
    }
    
    function Pop-Migration()
    {
        Remove-Table 'CustomTextImageFileGroup'
    }
'@ | New-TestMigration -Name 'CreateTableWithCustomFileStreamFileGroup'
        Invoke-RTRivet -Push 'CreateTableWithCustomFileStreamFileGroup' -ErrorAction SilentlyContinue
        $Global:Error.Count | Should -BeGreaterThan 0
        (Test-Table -Name 'CustomFileStreamFileGroup') | Should -BeFalse
    }
    
    It 'should create table with options' {
        @'
    function Push-Migration()
    {
        Add-Table 'AddTableWithOption' -Description 'Testing Add-Table migration' -Column {
            VarChar 'varchar' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
            BigInt 'id' -Identity
        } -Option 'data_compression = page'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'AddTableWithOption'
    }
'@ | New-TestMigration -Name 'CreateTableWithOption'
    
        Invoke-RTRivet -Push 'CreateTableWithOption' -ErrorAction SilentlyContinue
        
        if( $Global:Error )
        {
            $bingo = $Global:Error | Where-Object { $_ -like '*Cannot enable compression for object ''AddTableWithOption''*' }
            $bingo | Should -Not -BeNullOrEmpty
        }
        else
        {
            Assert-Table 'AddTableWithOption' -Description 'Testing Add-Table migration' -DataCompression 2
        }
    }
    
    It 'should escape names' {
        @'
    function Push-Migration
    {
        Add-Schema 'Add-Table'
        Add-Table 'Add-Table-Test' -SchemaName 'Add-Table'  {
            Int ID -Identity
        }
    }
    
    function Pop-Migration
    {
        Remove-Table 'Add-Table-Test' -SchemaName 'Add-Table'
        Remove-Schema 'Add-Table'
    }
    
'@ | New-TestMigration -Name 'AddTrigger'
    
        Invoke-RTRivet -Push 'AddTrigger'
    
        Assert-Table 'Add-Table-Test' -SchemaName 'Add-Table'
    }
}

function Init
{
    Start-RivetTest
}

function Reset
{
    Stop-RivetTest
}

Describe 'Add-Table.when setting default constraint name' {
    AfterEach { Reset }
    It 'should use that name' {
        Init
        GivenMigration -Name 'CustomDefaultConstraint' @'
function Push-Migration
{
    Add-Table 'Default' {
        int 'ID' -Default 0 -DefaultConstraintName 'DF_my_custom_constraint_name'
    }
}

function Pop-Migration
{
    Remove-Table 'Default'
}
'@
        WhenMigrating 'CustomDefaultConstraint'
        ThenDefaultConstraint 'DF_my_custom_constraint_name' -Is '0'
    }
}
