
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
        if( $PSBoundParameters.ContainsKey('Include') )
        {
            $optionalParams['Include'] = $Include
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
    Add-Table -Name 'Migrations' -Description 'some table' -Column {
        int 'ID' -Identity
        bigint 'BigID' -NotNull -Description 'some bigint column'
        nvarchar 'Name' -Size 241 -NotNull
        datetime2 'AtUtc' -NotNull
        decimal 'Dec' -Precision 4 -Scale 2
        float 'Fl' -Precision 5
        float 'bigger' -Precision 50
        smallint 'sparsesmallint' -Sparse
        nvarchar 'Korean' -Size 47 -Collation 'Korean_100_CS_AS_KS_WS_SC'
        uniqueidentifier 'GUID' -RowGuidCol
    }
    Add-PrimaryKey -TableName 'Migrations' -ColumnName 'ID'
    Add-DefaultConstraint -TableName 'Migrations' -ColumnName 'AtUtc' -Expression '(getutcdate())'
    Add-CheckConstraint -TableName 'Migrations' -Name 'CK_Migrations_Name' -Expression '([Name] = ''Fubar'')'
    Add-Index -TableName 'Migrations' -ColumnName 'BigID'
    Add-UniqueKey -TableName 'Migrations' -ColumnName 'Korean'
}

function Pop-Migration
{
    Remove-Table 'Migrations'
}
'@
    WhenExporting 'dbo.Migrations'
    ThenMigration -Not -HasContent 'Add-Schema -Name ''dbo'''
    ThenMigration -HasContent @'
    Add-Table -Name 'Migrations' -Description 'some table' -Column {
        int 'ID' -Identity
        bigint 'BigID' -NotNull -Description 'some bigint column'
        nvarchar 'Name' -Size 241 -NotNull
        datetime2 'AtUtc' -NotNull
        decimal 'Dec' -Precision 4 -Scale 2
        real 'Fl'
        float 'bigger'
        smallint 'sparsesmallint' -Sparse
        nvarchar 'Korean' -Size 47 -Collation 'Korean_100_CS_AS_KS_WS_SC'
        uniqueidentifier 'GUID' -RowGuidCol
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
    ThenMigration -HasContent 'Add-Index -TableName ''Migrations'' -ColumnName ''BigID'' -Name ''IX_Migrations_BigID'''
    ThenMigration -HasContent 'Add-UniqueKey -TableName ''Migrations'' -ColumnName ''Korean'' -Name ''AK_Migrations_Korean'''
    ThenMigration -HasContent 'Remove-Table -Name ''Migrations'''
    ThenMigration -Not -HasContent 'Remove-Schema'
    ThenMigration -Not -HasContent 'Remove-PrimaryKey'
    ThenMigration -Not -HasContent 'Remove-DefaultConstraint'
    ThenMigration -Not -HasContent 'Remove-CheckConstraint'
    ThenMigration -Not -HasContent 'Remove-Index'
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
    ThenMigration -HasContent 'Add-StoredProcedure -SchemaName ''export'' -Name ''DoSomething'' -Definition'
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
    Add-StoredProcedure -Name 'DoSomething' -Definition @'
as select 1
'@
"@
    ThenMigration -HasContent 'Remove-StoredProcedure -Name ''DoSomething'''
}

Describe 'Export-Migration.when exporting a stored procedure not added with Rivet' {
    Init
    GivenMigration @'
function Push-Migration
{
    Invoke-Ddl 'create procedure DoSomething as select 1'
}

function Pop-Migration
{
    Remove-StoredProcedure -Name 'DoSomething'
}
'@
    WhenExporting 'dbo.DoSomething'
    ThenMigration -HasContent @"
    Invoke-Ddl -Query @'
create procedure DoSomething as select 1
'@
"@
    ThenMigration -HasContent 'Remove-StoredProcedure -Name ''DoSomething'''
}

Describe 'Export-Migration.when exporting a view' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-View -Name 'ViewSomething' -Definition 'as select 1 as one'
}

function Pop-Migration
{
    Remove-View -Name 'ViewSomething'
}
'@
    WhenExporting 'dbo.ViewSomething'
    ThenMigration -HasContent @"
    Add-View -Name 'ViewSomething' -Definition @'
as select 1 as one
'@
"@
    ThenMigration -HasContent 'Remove-View -Name ''ViewSomething'''
}

Describe 'Export-Migration.when exporting a view not added with Rivet' {
    Init
    GivenMigration @'
function Push-Migration
{
    Invoke-Ddl 'create view ViewSomething as select 1 as one'
}

function Pop-Migration
{
    Remove-View -Name 'ViewSomething'
}
'@
    WhenExporting 'dbo.ViewSomething'
    ThenMigration -HasContent @"
    Invoke-Ddl -Query @'
create view ViewSomething as select 1 as one
'@
"@
    ThenMigration -HasContent 'Remove-View -Name ''ViewSomething'''
}

Describe 'Export-Migration.when exporting a function' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-UserDefinedFunction -Name 'CallSomething' -Definition '() returns tinyint as begin return 1 end'
    Add-UserDefinedFunction -Name 'CallTable' -Definition '() returns table as return( select 1 as name )'
}

function Pop-Migration
{
    Remove-UserDefinedFunction -Name 'CallTable'
    Remove-UserDefinedFunction -Name 'CallSomething'
}
'@
    WhenExporting 'dbo.Call*'
    ThenMigration -HasContent @"
    Add-UserDefinedFunction -Name 'CallSomething' -Definition @'
() returns tinyint as begin return 1 end
'@
"@
    ThenMigration -HasContent @"
    Add-UserDefinedFunction -Name 'CallTable' -Definition @'
() returns table as return( select 1 as name )
'@
"@
    ThenMigration -HasContent 'Remove-UserDefinedFunction -Name ''CallSomething'''
    ThenMigration -HasContent 'Remove-UserDefinedFunction -Name ''CallTable'''
}

Describe 'Export-Migration.when exporting a function not added with Rivet' {
    Init
    GivenMigration @'
function Push-Migration
{
    Invoke-Ddl 'create function CallSomething () returns tinyint as begin return 1 end'
}

function Pop-Migration
{
    Remove-UserDefinedFunction -Name 'CallSomething'
}
'@
    WhenExporting 'dbo.CallSomething'
    ThenMigration -HasContent @"
    Invoke-Ddl -Query @'
create function CallSomething () returns tinyint as begin return 1 end
'@
"@
    ThenMigration -HasContent 'Remove-UserDefinedFunction -Name ''CallSomething'''
}

Describe 'Export-Migration.when exporting entire database' {
    Init
    WhenExporting
    ThenMigration -Not -HasContent 'rivet'
    ThenNoErrors
}

Describe 'Export-Migration.when exporting data type' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Schema 'export'
    Add-DataType 'GUID' 'uniqueidentifier'
    Add-DataType -SchemaName 'export' 'GUID2' 'uniqueidentifier'
}
function Pop-Migration
{
    Remove-Datatype 'GUID'
    Remove-DataType -SchemaName 'export' 'GUID2'
    Remove-Schema 'export'
}
'@
    WhenExporting
    ThenMigration -HasContent 'Add-DataType -Name ''GUID'' -From ''uniqueidentifier'''
    ThenMigration -HasContent 'Add-DataType -SchemaName ''export'' -Name ''GUID2'' -From ''uniqueidentifier'''
    ThenMigration -HasContent 'Add-Schema -Name ''export'
    ThenMigration -HasContent 'Remove-DataType -Name ''GUID'''
    ThenMigration -HasContent 'Remove-DataType -SchemaName ''export'' -Name ''GUID2'''
    ThenMigration -HasContent 'Remove-Schema -Name ''export'''
}

Describe 'Export-Migration.when exporting filtered data type' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Schema 'export'
    Add-DataType 'GUID' 'uniqueidentifier'
    Add-DataType -SchemaName 'export' 'GUID2' 'uniqueidentifier'
}
function Pop-Migration
{
    Remove-Datatype 'GUID'
    Remove-DataType -SchemaName 'export' 'GUID2'
    Remove-Schema 'export'
}
'@
    WhenExporting 'dbo.*'
    ThenMigration -HasContent 'Add-DataType -Name ''GUID'' -From ''uniqueidentifier'''
    ThenMigration -Not -HasContent 'Add-DataType -SchemaName ''export'' -Name ''GUID2'' -From ''uniqueidentifier'''
    ThenMigration -Not -HasContent 'Add-Schema -Name ''export'
    ThenMigration -HasContent 'Remove-DataType -Name ''GUID'''
    ThenMigration -Not -HasContent 'Remove-DataType -SchemaName ''export'' -Name ''GUID2'''
    ThenMigration -Not -HasContent 'Remove-Schema -Name ''export'''}

Describe 'Export-Migration.when identity has custom seed and increment' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Table -Name 'SeedAndIncrement' -Column {
        int 'ID' -Identity -Seed 1000 -Increment 7
        nvarchar 'OtherColumn' -Size 50
    }
}

function Pop-Migration
{
    Remove-Table 'SeedAndIncrement'
}
'@
    WhenExporting 'dbo.SeedAndIncrement'
    ThenMigration -HasContent 'int ''ID'' -Identity -Seed 1000 -Increment 7'
    ThenMigration -HasContent 'nvarchar ''OtherColumn'' -Size 50'
}

Describe 'Export-Migration.when exporting an index' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Table -Name 'Indexes' -Column {
        int ID -NotNull
        int ID2 -NotNull
        int ID3 -NotNull
        int ID4 -NotNull
        int ID5 -NotNull
        int ID6 -NotNull
    }
    Add-Index -TableName 'Indexes' -ColumnName 'ID'
    Add-Index -TableName 'Indexes' -Columnname 'ID2','ID3'
    Add-Index -TableName 'Indexes' -ColumnName 'ID4' -Unique
    Add-Index -TableName 'Indexes' -ColumnName 'ID5' -Clustered
    Add-Index -TableName 'Indexes' -ColumnName 'ID6' -Where 'ID6<=100'

    Add-Schema -Name 'export'
    Add-Table -SchemaName 'export' -Name 'Indexes2' -Column {
        int ID
    }
    Add-Index -SchemaName 'export' -TableName 'Indexes2' -ColumnName 'ID'
}
function Pop-Migration
{
    Remove-Table 'Indexes'
    Remove-Table -SchemaName 'export' -Name 'Indexes2'
    Remove-Schema 'export'
}
'@
    WhenExporting '*.*_Indexes*'
    ThenMigration -HasContent 'Add-Index -TableName ''Indexes'' -ColumnName ''ID'' -Name ''IX_Indexes_ID'''
    ThenMigration -HasContent 'Add-Index -TableName ''Indexes'' -Columnname ''ID2'',''ID3'' -Name ''IX_Indexes_ID2_ID3'''
    ThenMigration -HasContent 'Add-Index -TableName ''Indexes'' -ColumnName ''ID4'' -Name ''UIX_Indexes_ID4'' -Unique'
    ThenMigration -HasContent 'Add-Index -TableName ''Indexes'' -ColumnName ''ID5'' -Name ''IX_Indexes_ID5'' -Clustered'
    ThenMigration -HasContent 'Add-Index -TableName ''Indexes'' -ColumnName ''ID6'' -Name ''IX_Indexes_ID6'' -Where ''([ID6]<=(100))'''
    ThenMigration -HasContent 'Add-Index -SchemaName ''export'' -TableName ''Indexes2'' -ColumnName ''ID'' -Name ''IX_export_Indexes2_ID'''
    ThenMigration -Not -HasContent 'Add-Index -SchemaName ''export'' -TableName ''Indexes2'' -ColumnName '''' -Name '''''

    ThenMigration -HasContent 'Remove-Index -TableName ''Indexes'' -Name ''IX_Indexes_ID'''
    ThenMigration -HasContent 'Remove-Index -TableName ''Indexes'' -Name ''IX_Indexes_ID2_ID3'''
    ThenMigration -HasContent 'Remove-Index -TableName ''Indexes'' -Name ''UIX_Indexes_ID4'''
    ThenMigration -HasContent 'Remove-Index -TableName ''Indexes'' -Name ''IX_Indexes_ID5'''
    ThenMigration -HasContent 'Remove-Index -TableName ''Indexes'' -Name ''IX_Indexes_ID6'''
    ThenMigration -HasContent 'Remove-Index -SchemaName ''export'' -TableName ''Indexes2'' -Name ''IX_export_Indexes2_ID'''
}

Describe 'Export-Migration.when exporting unique keys' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Schema 'export'
    Add-Table -SchemaName 'export' -Name 'UK' {
        int 'ID' -NotNull
        int 'ID2' -NotNull
    }
    Add-UniqueKey -SchemaName 'export' -TableName 'UK' -ColumnName 'ID','ID2'

    Add-Table -Name 'UK2' {
        int 'ID3' -NotNull
        int 'ID4' -NotNull
        int 'ID5' -NotNull
    }
    Add-UniqueKey -TableName 'UK2' -ColumnName 'ID3','ID4'
    Add-UniqueKey -TableName 'UK2' -ColumnName 'ID5' -Clustered
}
function Pop-Migration
{
    Remove-Table 'UK2'
    Remove-Table -SchemaName 'export' 'UK'
    Remove-Schema 'export'
}
'@
    WhenExporting '*.*_ID*'
    ThenMigration -Not -HasContent 'Add-Table'
    ThenMigration -HasContent 'Add-Schema -Name ''export'''
    ThenMigration -HasContent 'Add-UniqueKey -SchemaName ''export'' -TableName ''UK'' -ColumnName ''ID'',''ID2'' -Name ''AK_export_UK_ID_ID2'''
    ThenMigration -HasContent 'Add-UniqueKey -TableName ''UK2'' -ColumnName ''ID3'',''ID4'' -Name ''AK_UK2_ID3_ID4'''
    ThenMigration -HasContent 'Add-UniqueKey -TableName ''UK2'' -ColumnName ''ID5'' -Clustered -Name ''AK_UK2_ID5'''
    ThenMigration -HasContent 'Remove-Schema -Name ''export'''
    ThenMigration -HasContent 'Remove-UniqueKey -SchemaName ''export'' -TableName ''UK'' -Name ''AK_export_UK_ID_ID2'''
    ThenMigration -HasContent 'Remove-UniqueKey -TableName ''UK2'' -Name ''AK_UK2_ID3_ID4'''
    ThenMigration -HasContent 'Remove-UniqueKey -TableName ''UK2'' -Name ''AK_UK2_ID5'''
}
