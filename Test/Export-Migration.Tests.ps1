
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
        $Include,

        [Switch]
        $SkipVerification
    )

    Start-RivetTest
    try
    {
        $migrationPath = ''
        if( $migration )
        {
            $migrationPath = $migration | New-TestMigration -Name 'ExportMigration'
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

        if( -not $SkipVerification )
        {
            It ('should export a runnable migration') {
                # Now, check that the migration is runnable
                Invoke-RTRivet -Pop

                $migration | Set-Content -Path $migrationPath
                Invoke-RTRivet -Push -ErrorAction Stop
                Invoke-RTRivet -Pop -ErrorAction Stop
            }
        }
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
    Add-DataType -Name 'CUI' -From 'char(8)'
    Add-Table -Name 'Migrations' -Description 'some table''s description' -Column {
        int 'ID' -Identity
        bigint 'BigID' -NotNull -Description 'some bigint column''s description'
        nvarchar 'Name' -Size 241 -NotNull
        datetime2 'AtUtc' -NotNull
        decimal 'Dec' -Precision 4 -Scale 2
        float 'Fl' -Precision 5
        float 'bigger' -Precision 50
        smallint 'sparsesmallint' -Sparse
        nvarchar 'Korean' -Size 47 -Collation 'Korean_100_CS_AS_KS_WS_SC'
        uniqueidentifier 'GUID' -RowGuidCol
        New-Column -DataType 'text' -Name 'textcolumn' -Description 'a text column'
        New-Column -DataType 'ntext' -Name 'ntextcolumn' -NotNull
        New-Column -DataType 'image' -Name 'imagecolumn'
        New-Column -DataType 'sysname' -Name 'sysnamecolumn' -NotNull 
        New-Column -DataType 'sql_variant' -Name 'sql_variantcolumn' -Sparse
        New-Column -DataType 'CUI' -Name 'CUI' -NotNull
    }
    Add-PrimaryKey -TableName 'Migrations' -ColumnName 'ID'
    Add-DefaultConstraint -TableName 'Migrations' -ColumnName 'AtUtc' -Expression '(getutcdate())'
    Add-CheckConstraint -TableName 'Migrations' -Name 'CK_Migrations_Name' -Expression '([Name] = ''Fubar'')'
    Add-Index -TableName 'Migrations' -ColumnName 'BigID'
    Add-UniqueKey -TableName 'Migrations' -ColumnName 'Korean'
    Add-Trigger -Name 'MigrationsTrigger' -Definition 'ON [dbo].[Migrations] for insert as select 1'
}

function Pop-Migration
{
    Remove-Table 'Migrations'
    Remove-DataType 'CUI'
}
'@
    WhenExporting
    ThenMigration -Not -HasContent 'Add-Schema -Name ''dbo'''
    ThenMigration -HasContent @'
    Add-Table -Name 'Migrations' -Description 'some table''s description' -Column {
        int 'ID' -Identity
        bigint 'BigID' -NotNull -Description 'some bigint column''s description'
        nvarchar 'Name' -Size 241 -NotNull
        datetime2 'AtUtc' -NotNull
        decimal 'Dec' -Precision 4 -Scale 2
        real 'Fl'
        float 'bigger'
        smallint 'sparsesmallint' -Sparse
        nvarchar 'Korean' -Size 47 -Collation 'Korean_100_CS_AS_KS_WS_SC'
        uniqueidentifier 'GUID' -RowGuidCol
        New-Column -DataType 'text' -Name 'textcolumn' -Description 'a text column'
        New-Column -DataType 'ntext' -Name 'ntextcolumn' -NotNull
        New-Column -DataType 'image' -Name 'imagecolumn'
        New-Column -DataType 'sysname' -Name 'sysnamecolumn' -NotNull
        New-Column -DataType 'sql_variant' -Name 'sql_variantcolumn' -Sparse
        New-Column -DataType 'CUI' -Name 'CUI' -NotNull
    }
'@
    ThenMigration -HasContent @'
    Add-PrimaryKey -TableName 'Migrations' -ColumnName 'ID' -Name 'PK_Migrations'
'@
    ThenMigration -HasContent @'
    Add-DefaultConstraint -TableName 'Migrations' -ColumnName 'AtUtc' -Name 'DF_Migrations_AtUtc' -Expression '(getutcdate())'
'@
    ThenMigration -HasContent @'
    Add-CheckConstraint -TableName 'Migrations' -Name 'CK_Migrations_Name' -Expression '([Name]=''Fubar'')'
'@
    ThenMigration -HasContent 'Add-Index -TableName ''Migrations'' -ColumnName ''BigID'' -Name ''IX_Migrations_BigID'''
    ThenMigration -HasContent 'Add-UniqueKey -TableName ''Migrations'' -ColumnName ''Korean'' -Name ''AK_Migrations_Korean'''
    ThenMigration -HasContent 'Add-Trigger -Name ''MigrationsTrigger'' -Definition @''
ON [dbo].[Migrations] for insert as select 1
''@'
    ThenMigration -HasContent 'Remove-Table -Name ''Migrations'''
    ThenMigration -Not -HasContent 'Remove-Schema'
    ThenMigration -Not -HasContent 'Remove-PrimaryKey'
    ThenMigration -Not -HasContent 'Remove-DefaultConstraint'
    ThenMigration -Not -HasContent 'Remove-CheckConstraint'
    ThenMigration -Not -HasContent 'Remove-Index'
    ThenMigration -Not -HasContent 'Remove-UniqueKey'
    ThenMigration -Not -HasContent 'Remove-Trigger'
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
        char 'YN' -Size 1
    }
    Add-DefaultConstraint -TableName 'Fubar' -ColumnName 'ID' -Expression '1'
    Add-DefaultConstraint -TableName 'Fubar' -ColumnName 'YN' -Expression '''N'''
}

function Pop-Migration
{
    Remove-Table 'Fubar'
}
'@
    WhenExporting 'dbo.DF_Fubar_*' -SkipVerification
    ThenMigration -HasContent 'Add-DefaultConstraint -TableName ''Fubar'' -ColumnName ''ID'' -Name ''DF_Fubar_ID'' -Expression ''((1))'''
    ThenMigration -HasContent 'Add-DefaultConstraint -TableName ''Fubar'' -ColumnName ''YN'' -Name ''DF_Fubar_YN'' -Expression ''(''''N'''')'''
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
    WhenExporting 'dbo.PK_Fubar' -SkipVerification
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
        char 'YN' -Size 1
    }
    Add-CheckConstraint -TableName 'CheckConstraint' -Name 'CK_CheckConstraint_ID' -Expression '[ID] > 0 and [ID] < 10'
    Add-CheckConstraint -TableName 'CheckConstraint' -Name 'CK_CheckConstraint_YN' -Expression '[YN] = ''Y'' or [YN] = ''N'''
}

function Pop-Migration
{
    Remove-Table 'CheckConstraint'
}
'@
    WhenExporting 'dbo.CK_CheckConstraint_*' -SkipVerification
    ThenMigration -HasContent 'Add-CheckConstraint -TableName ''CheckConstraint'' -Name ''CK_CheckConstraint_ID'' -Expression ''([ID]>(0) AND [ID]<(10))'''
    ThenMigration -HasContent 'Add-CheckConstraint -TableName ''CheckConstraint'' -Name ''CK_CheckConstraint_YN'' -Expression ''([YN]=''''Y'''' OR [YN]=''''N'''')'
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
    Add-UserDefinedFunction -Name 'CallInlineTable' -Definition '() returns table as return( select 1 as name )'
    Add-UserDefinedFunction -Name 'CallTable' -Definition '() returns @Table TABLE ( ID int ) as begin insert into @Table select 1 return end'
}

function Pop-Migration
{
    Remove-UserDefinedFunction -Name 'CallTable'
    Remove-UserDefinedFunction -Name 'CallInlineTable'
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
    Add-UserDefinedFunction -Name 'CallInlineTable' -Definition @'
() returns table as return( select 1 as name )
'@
"@
    ThenMigration -HasContent @"
    Add-UserDefinedFunction -Name 'CallTable' -Definition @'
() returns @Table TABLE ( ID int ) as begin insert into @Table select 1 return end
'@
"@
    ThenMigration -HasContent 'Remove-UserDefinedFunction -Name ''CallSomething'''
    ThenMigration -HasContent 'Remove-UserDefinedFunction -Name ''CallInlineTable'''
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
    WhenExporting -SkipVerification
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
    Add-DataType 'SUI' 'int'
    Add-DataType 'CUI' 'char(8)'
    Add-DataType 'mymoney' 'decimal(20,2) not null'
    Add-DataType 'lotsa' 'varchar(max)'
    Add-DataType -SchemaName 'export' 'GUID2' 'uniqueidentifier'
}
function Pop-Migration
{
    Remove-DataType -SchemaName 'export' 'GUID2'
    Remove-DataType 'lotsa'
    Remove-DataType 'mymoney'
    Remove-DataType 'CUI'
    Remove-DataType 'SUI'
    Remove-Datatype 'GUID'
    Remove-Schema 'export'
}
'@
    WhenExporting
    ThenMigration -HasContent 'Add-DataType -Name ''GUID'' -From ''uniqueidentifier'''
    ThenMigration -HasContent 'Add-DataType -Name ''SUI'' -From ''int'''
    ThenMigration -HasContent 'Add-DataType -Name ''CUI'' -From ''char(8)'''
    ThenMigration -HasContent 'Add-DataType -Name ''mymoney'' -From ''decimal(20,2) not null'''
    ThenMigration -HasContent 'Add-DataType -Name ''lotsa'' -From ''varchar(max)'''
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
    WhenExporting '*.*_Indexes*' -SkipVerification
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
    WhenExporting '*.*_ID*' -SkipVerification
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

Describe 'Export-Migration.when exporting triggers' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Table -Name 'TriggerSource' {
        int 'ID' -NotNull
    }

    Add-Trigger -Name 'TableTrigger' -Definition 'ON [dbo].[TriggerSource] for insert as select 1'

    Add-Schema -SchemaName 'export'
    Add-Table -SchemaName 'export' -Name 'TriggerSource2' {
        int 'ID' -NotNull
    }
    Add-Trigger -SchemaName 'export' -Name 'TableTrigger2' -Definition 'ON [export].[TriggerSource2] for insert as select 1'

    Invoke-Ddl 'create trigger [TableTriggerDB] on database for create_table as select 1'
}
function Pop-Migration
{
    Invoke-Ddl 'drop trigger [TableTriggerDB] on database'
    Remove-Table -SchemaName 'export' 'TriggerSource2'
    Remove-Schema 'export'
    Remove-Table 'TriggerSource'
}
'@
    WhenExporting '*.TableTrigger*' -SkipVerification
    ThenMigration -Not -HasContent 'Add-Table'
    ThenMigration -Not -HasContent 'TableTriggerDB'
    ThenMigration -HasContent 'Add-Trigger -Name ''TableTrigger'' -Definition @''
ON [dbo].[TriggerSource] for insert as select 1
''@'
    ThenMigration -HasContent 'Add-Trigger -SchemaName ''export'' -Name ''TableTrigger2'' -Definition @''
ON [export].[TriggerSource2] for insert as select 1
''@'
}


Describe 'Export-Migration.when exporting synonyms' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Table -Name 'Target' {
        int 'ID' -NotNull
    }

    Add-Synonym -Name 'Syn1' -TargetObjectName 'Target'
    Add-Synonym -Name 'AnotherSyn' -TargetObjectName 'Target'

    Add-Schema 'export'
    Add-Table -SchemaName 'export' -Name 'Target2' {
        int 'ID' -NotNull
    }

    Add-Synonym -SchemaName 'export' -Name 'Syn2' -TargetObjectName 'Target'
    Add-Synonym -SchemaName 'export' -Name 'Syn3' -TargetSchemaName 'export' -TargetObjectName 'Target2'
}
function Pop-Migration
{
    Remove-Synonym -SchemaName 'export' 'Syn3'
    Remove-Synonym -SchemaName 'export' 'Syn2'
    Remove-Synonym 'AnotherSyn'
    Remove-Synonym 'Syn1'
    Remove-Table 'Target'
    Remove-Table -SchemaName 'export' 'Target2'
    Remove-Schema 'export'
}
'@
    WhenExporting '*.Syn*'
    ThenMigration -Not -HasContent 'Add-Table'
    ThenMigration -Not -HasContent 'AnotherSyn'
    ThenMigration -HasContent 'Add-Synonym -Name ''Syn1'' -TargetSchemaName ''dbo'' -TargetObjectName ''Target'''
    ThenMigration -HasContent 'Add-Synonym -SchemaName ''export'' -Name ''Syn2'' -TargetSchemaName ''dbo'' -TargetObjectName ''Target'''
    ThenMigration -HasContent 'Add-Synonym -SchemaName ''export'' -Name ''Syn3'' -TargetSchemaName ''export'' -TargetObjectName ''Target2'''
    ThenMigration -HasContent 'Remove-Synonym -Name ''Syn1'''
    ThenMigration -HasContent 'Remove-Synonym -SchemaName ''export'' -Name ''Syn2'''
    ThenMigration -HasContent 'Remove-Synonym -SchemaName ''export'' -Name ''Syn3'''
}

Describe 'Export-Migration.when exporting foreign keys' {
    Init
    GivenMigration @'
function Push-Migration
{
    Add-Table 'Table' {
        int 'Table_ID' -Identity
        int 'Table_ID2' -NotNull
    }
    Add-PrimaryKey -TableName 'Table' -ColumnName 'Table_ID','Table_ID2'

    Add-Table 'Table2' {
        int 'Table2_ID' -Identity
        int 'Table2_ID2' -NotNull
    }
    Add-PrimaryKey -TableName 'Table2' -ColumnName 'Table2_ID','Table2_ID2'

    Add-ForeignKey 'Table' -ColumnName 'Table_ID','Table_ID2' -References 'Table2' -ReferencedColumn 'Table2_ID','Table2_ID2'

    Add-Schema 'export'

    Add-Table -SchemaName 'export' 'Table3' {
        int 'Table3_ID' -NotNull
    }
    Add-PrimaryKey -SchemaName 'export' -TableName 'Table3' -ColumnName 'Table3_ID'

    Add-Table -SchemaName 'export' 'Table4' {
        int 'Table4_ID' -NotNull
    }
    Add-PrimaryKey -SchemaName 'export' -TableName 'Table4' -ColumnName 'Table4_ID'
    
    Add-ForeignKey -SchemaName 'export' -TableName 'Table3' -ColumnName 'Table3_ID' -ReferencesSchema 'export' -References 'Table4' -ReferencedColumn 'Table4_ID' -OnDelete 'CASCADE' -OnUpdate 'CASCADE' -NotForReplication -NoCheck
}
function Pop-Migration
{
    Remove-Table -SchemaName 'export' -Name 'Table3'
    Remove-Table -SchemaName 'export' -Name 'Table4'
    Remove-Table -Name 'Table'
    Remove-Table -Name 'Table2'
    Remove-Schema 'export'
}
'@
    WhenExporting '*.FK_*' -SkipVerification
    ThenMigration -Not -HasContent 'Add-Table'
    ThenMigration -Not -HasContent 'Add-PrimaryKey'
    ThenMigration -HasContent 'Add-ForeignKey -TableName ''Table'' -ColumnName ''Table_ID'',''Table_ID2'' -References ''Table2'' -ReferencedColumn ''Table2_ID'',''Table2_ID2'' -Name ''FK_Table_Table2'''
    ThenMigration -HasContent 'Add-ForeignKey -SchemaName ''export'' -TableName ''Table3'' -ColumnName ''Table3_ID'' -ReferencesSchema ''export'' -References ''Table4'' -ReferencedColumn ''Table4_ID'' -Name ''FK_export_Table3_export_Table4'' -OnDelete ''CASCADE'' -OnUpdate ''CASCADE'' -NotForReplication -NoCheck'
}
