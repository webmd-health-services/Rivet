
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

$migration = $null

function Init
{
    $script:migration = $null
}

function GivenDatabase
{
    param(
        [Parameter(Mandatory)]
        [string[]]
        $Name
    )

    $script:databases += $Name
}

function GivenMigration
{
    param(
        [Parameter(Mandatory)]
        [string]
        $Content
    )

    $script:migration = $Content
}

function ThenNoErrors
{
    It ('should not write any errors') {
        $Global:Error | Should -BeNullOrEmpty
    }
}

function ThenMigration
{
    param(
        [Switch]
        $Not,

        [Parameter(Mandatory)]
        [string]
        $HasContent
    )

    It ('should export operations') {
        if( $Not )
        {
            ($migration -join [Environment]::NewLine) | Should -Not -BeLike ('*{0}*' -f [wildcardpattern]::Escape($HasContent))
        }
        else
        {
            ($migration -join [Environment]::NewLine) | Should -BeLike ('*{0}*' -f [wildcardpattern]::Escape($HasContent))
        }
    }
}

function WhenExporting
{
    [CmdletBinding()]
    param(
        [string[]]
        $Include
    )

    Start-RivetTest
    try
    {
        if( $migration )
        {
            $migration | New-TestMigration -Name 'ExportMigration'
        }
        Invoke-RTRivet -Push
        $optionalParams = @{}
        if( $PSBoundParameters.ContainsKey('Name') )
        {
            $optionalParams['Include'] = $Name
        }

        $Global:Error.Clear()

        $script:migration = Export-Migration -SqlServerName $RTServer -Database $RTDatabaseName @optionalParams
        Write-Debug -Message ($migration -join [Environment]::NewLine)
    }
    finally
    {
        Stop-RivetTest
    }
}

Describe 'Export-Migration.when exporting a table' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Table -Name 'Migrations' -Column {
        bigint 'ID' -NotNull
        nvarchar 'Name' -Size 241 -NotNull
        datetime2 'AtUtc' -NotNull
    }
    Add-PrimaryKey -TableName 'Migrations' -ColumnName 'ID'
    Add-DefaultConstraint -TableName 'Migrations' -ColumnName 'AtUtc' -Expression '(getutcdate())'
    Add-CheckConstraint -TableName 'Migrations' -Name 'CK_Migrations_Name' -Expression '([Name] = ''Fubar'')'
}

function Pop-Migration
{
    Remove-Table 'Migrations'
}
'@
    WhenExporting 'dbo.Migrations'
    ThenMigration -Not -HasContent 'Add-Schema -Name ''dbo'''
    ThenMigration -HasContent @'
    Add-Table -Name 'Migrations' -Column {
        bigint 'ID' -NotNull
        nvarchar 'Name' -Size 241 -NotNull
        datetime2 'AtUtc' -NotNull
    }
'@
    ThenMigration -HasContent @'
    Add-PrimaryKey -TableName 'Migrations' -ColumnName 'ID' -Name 'PK_Migrations'
'@
    ThenMigration -HasContent @'
    Add-DefaultConstraint -TableName 'Migrations' -ColumnName 'AtUtc' -Name 'DF_Migrations_AtUtc' -Expression '(getutcdate())'
'@
    ThenMigration -HasContent @'
    Add-CheckConstraint -TableName 'Migrations' -Name 'CK_Migrations_Name' -Expression '([Name]='Fubar')'
'@
    ThenMigration -HasContent 'Remove-Table -Name ''Migrations'''
    ThenMigration -Not -HasContent 'Remove-Schema'
    ThenMigration -Not -HasContent 'Remove-PrimaryKey'
    ThenMigration -Not -HasContent 'Remove-DefaultConstraint'
    ThenMigration -Not -HasContent 'Remove-CheckConstraint'
}

Describe 'Export-Migration.when exporting with wildcards' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Schema -Name 'export'

    Add-Table -SchemaName 'export' -Name 'Migrations' -Column {
        bigint 'ID' -NotNull
        nvarchar 'Name' -Size 241 -NotNull
        datetime2 'AtUtc' -NotNull
    }
    Add-PrimaryKey -SchemaName 'export' -TableName 'Migrations' -ColumnName 'ID'

    Add-StoredProcedure -SchemaName 'export' -Name 'DoSomething' -Definition 'as select 1'

    Add-StoredProcedure -Name 'DoSomethingElse' -Definition 'as select 1'
}

function Pop-Migration
{
    Remove-StoredProcedure -Name 'DoSomethingElse'
    Remove-StoredProcedure -SchemaName 'export' -Name 'DoSomething'
    Remove-Table -SchemaName 'export' -Name 'Migrations'
    Remove-Schema 'export'
}
'@
    WhenExporting 'export.*'
    ThenMigration -HasContent @'
    Add-Table -SchemaName 'export' -Name 'Migrations' -Column {
        bigint 'ID' -NotNull
        nvarchar 'Name' -Size 241 -NotNull
        datetime2 'AtUtc' -NotNull
    }
'@
    ThenMigration -HasContent 'Add-PrimaryKey -SchemaName ''export'''
    ThenMigration -HasContent 'Invoke-Ddl -Query @''create procedure [export].[DoSomething]'
    ThenMigration -Not -HasContent 'DoSomethingElse'
}

Describe 'Export-Migration.when exporting a default constraint' {
    Init
    GivenMigration @'
function Push-Migration 
{
    Add-Table 'Fubar' {
        int 'ID'
    }
    Add-DefaultConstraint -TableName 'Fubar' -ColumnName 'ID' -Expression '1'
}

function Pop-Migration
{
    Remove-Table 'Fubar'
}
'@
    WhenExporting 'dbo.DF_Fubar_ID'
    ThenMigration -HasContent 'Add-DefaultConstraint -TableName ''Fubar'' -ColumnName ''ID'' -Name ''DF_Fubar_ID'' -Expression ''((1))'''
    ThenMigration -HasContent 'Remove-DefaultConstraint -TableName ''Fubar'' -Name ''DF_Fubar_ID'''
}

Describe 'Export-Migration.when exporting a primary key' {
    Init
    GivenMigration @'
function Push-Migration 
{
    Add-Table 'Fubar' {
        int 'ID' -NotNull
    }
    Add-PrimaryKey -TableName 'Fubar' -ColumnName 'ID'
}

function Pop-Migration
{
    Remove-Table 'Fubar'
}
'@
    WhenExporting 'dbo.PK_Fubar'
    ThenMigration -HasContent 'Add-PrimaryKey -TableName ''Fubar'' -ColumnName ''ID'' -Name ''PK_Fubar'''
    ThenMigration -HasContent 'Remove-PrimaryKey -TableName ''Fubar'' -Name ''PK_Fubar'''
}

Describe 'Export-Migration.when exporting a check constraint' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Table 'CheckConstraint' {
        int ID
    }
    Add-CheckConstraint -TableName 'CheckConstraint' -Name 'CK_CheckConstraint_ID' -Expression '[ID] > 0 and [ID] < 10'
}

function Pop-Migration
{
    Remove-Table 'CheckConstraint'
}
'@
    WhenExporting 'dbo.CK_CheckConstraint_ID'
    ThenMigration -HasContent 'Add-CheckConstraint -TableName ''CheckConstraint'' -Name ''CK_CheckConstraint_ID'' -Expression ''([ID]>(0) AND [ID]<(10))'''
    ThenMigration -HasContent 'Remove-CheckConstraint -TableName ''CheckConstraint'' -Name ''CK_CheckConstraint_ID'''
    ThenMigration -Not -HasContent 'Add-Table'
}

Describe 'Export-Migration.when exporting a stored procedure' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-StoredProcedure -Name 'DoSomething' -Definition 'as select 1'
}

function Pop-Migration
{
    Remove-StoredProcedure -Name 'DoSomething'
}
'@
    WhenExporting 'dbo.DoSomething'
    ThenMigration -HasContent @"
    Invoke-Ddl -Query @'CREATE procedure [dbo].[DoSomething] as select 1
"@
    ThenMigration -HasContent 'Remove-StoredProcedure -Name ''DoSomething'''
}

Describe 'Export-Migration.when exporting entire database' {
    Init
    WhenExporting
    ThenMigration -Not -HasContent 'rivet'
    ThenNoErrors
}
