#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

$checkpointedMigrations = [System.Collections.ArrayList]::new()
$migrationPaths = [System.Collections.ArrayList]::new()
$existingSchemaContents = @"
function Push-Migration
{
    Add-Table -Name 'Existing' -Column {
        int 'ID' -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'Existing'
}
"@

function Init
{
    $Global:Error.Clear()
    $script:checkpointedMigrations = [System.Collections.ArrayList]::new()
    $script:migrationPaths = [System.Collections.ArrayList]::new()
    Start-RivetTest
}

function GivenMigrationContent
{
    param(
        [Parameter(Mandatory)]
        [String] $Content,

        [String[]] $Database
    )

    if(-not $Database )
    {
        $Database = $RTDatabaseName
    }

    foreach( $databaseName in $Database )
    {
        $path = $Content | New-TestMigration -Name 'CheckpointMigration' -DatabaseName $databaseName
        $script:migrationPaths.Add($path)
    }
}

function Reset
{
    param(
        [String[]] $Database
    )

    if( -not $Database )
    {
        $Database = $RTDatabaseName
    }

    foreach( $databaseItem in $Database )
    {
        Remove-RivetTestDatabase -Name $databaseItem
    }
}

function ThenFailed
{
    param(
        [String] $WithError
    )

    It ('should fail') {
        $Global:Error | Should -Match $WithError
    }
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
        [Switch] $Not,

        [Parameter(Mandatory)]
        [String] $HasContent,

        [Parameter(Mandatory)]
        [String[]] $Database
    )

    foreach( $databaseItem in $Database )
    {
        $migration = $script:checkpointedMigrations | Where-Object {$_.Database -eq $databaseItem}

        It ('should checkpoint migration') {
            if( $Not )
            {
                ($migration.Migration -join [Environment]::NewLine) | Should -Not -BeLike ('*{0}*' -f [wildcardpattern]::Escape($HasContent))
            }
            else
            {
                ($migration.Migration -join [Environment]::NewLine) | Should -BeLike ('*{0}*' -f [wildcardpattern]::Escape($HasContent))
            }
        }
    }
}

function ThenSchemaFileRunnable
{
    foreach( $path in $script:migrationPaths )
    {
        $databaseName = $path.Directory.Parent.Name
        $schemaFilePath = Join-Path -Path (Split-Path $path) -ChildPath 'schema.ps1'
        $schemaFileContents = Get-Content -Path $schemaFilePath
        $checkpointedMigration = @{
            Database = $path.Directory.Parent.Name;
            Migration = $schemaFileContents
        }
        $script:checkpointedMigrations.Add($checkpointedMigration)
        It ('should export a runnable migration') {
            Remove-RivetTestDatabase -Name $databaseName
            # Now, check that the migration is runnable
            Invoke-RTRivet -Push -Database $databaseName -ErrorAction Stop
            Invoke-RTRivet -Pop -Database $databaseName -ErrorAction Stop
        }
    }
}

function WhenCheckpointingMigration
{
    [CmdletBinding()]
    param(
        [String[]] $Database,

        [Switch] $Force,

        [Switch] $ExistingSchemaFile,

        [String[]] $Exclude
    )

    if(-not $Database )
    {
        $Database = $RTDatabaseName
    }

    if( $ExistingSchemaFile )
    {
        foreach( $path in $script:migrationPaths )
        {
            Set-Content -Path (Join-Path -Path $path.Directory.FullName -ChildPath 'schema.ps1') -Value $existingSchemaContents 
        }
    }

    foreach( $migration in $Exclude )
    {
        $migrationPathToRemove = $script:migrationPaths | Where-Object {$_ -like $migration}
        if( $migrationPathToRemove )
        {
            $script:migrationPaths.Remove($migrationPathToRemove)
        }
    }

    Invoke-RTRivet -Checkpoint -Database $Database -Force:$Force
}

Describe 'Checkpoint-Migration.when there are multiple databases' {
    Init
    GivenMigrationContent -Content @'
function Push-Migration
{
    Add-Table -Name 'Replicated' -Column {
        int 'ID' -Identity
    }
    Add-Table -Name 'NotReplicated' -Column {
        int 'ID' -Identity -NotForReplication
    }
}

function Pop-Migration
{
    Remove-Table 'Replicated'
    Remove-Table 'NotReplicated'
}
'@ -Database ('RivetTest', 'RivetTest2')
    Invoke-RTRivet -Push -Database ('RivetTest', 'RivetTest2')
    WhenCheckpointingMigration -Database ('RivetTest', 'RivetTest2')
    ThenSchemaFileRunnable
    ThenMigration -HasContent @'
    Add-Table -Name 'Replicated' -Column {
        int 'ID' -Identity
    }
'@ -Database ('RivetTest', 'RivetTest2')
    ThenMigration -HasContent @'
    Add-Table -Name 'NotReplicated' -Column {
        int 'ID' -Identity -NotForReplication
    }
'@ -Database ('RivetTest', 'RivetTest2')
    ThenNoErrors
    Reset -Database ('RivetTest', 'RivetTest2')
}

Describe 'Checkpoint-Migration.when schema.ps1 file already exists' {
    Init
    GivenMigrationContent @'
function Push-Migration
{
    Add-Table -Name 'NotReplicated' -Column {
        int 'ID' -Identity -NotForReplication
    }
}

function Pop-Migration
{
    Remove-Table 'NotReplicated'
}
'@
    Invoke-RTRivet -Push -Database $RTDatabaseName
    WhenCheckpointingMigration -ExistingSchemaFile -ErrorAction SilentlyContinue
    ThenFailed -WithError 'schema.ps1" already exists.'
    Reset
}

Describe 'Checkpoint-Migration.when schema.ps1 file already exists but -Force switch is given' {
    Init
    GivenMigrationContent @'
function Push-Migration
{
    Add-Table -Name 'NotReplicated' -Column {
        int 'ID' -Identity -NotForReplication
    }
}

function Pop-Migration
{
    Remove-Table 'NotReplicated'
}
'@
    Invoke-RTRivet -Push -Database $RTDatabaseName
    WhenCheckpointingMigration -ExistingSchemaFile -Force
    ThenSchemaFileRunnable
    ThenMigration -HasContent @'
    Add-Table -Name 'NotReplicated' -Column {
        int 'ID' -Identity -NotForReplication
    }
'@ -Database $RTDatabaseName
    ThenNoErrors
    Reset
}

Describe 'Checkpoint-Migration.when checkpointing a migration' {
    Init
    GivenMigrationContent @'
function Push-Migration
{
    Add-DataType -Name 'CID' -From 'char(8)'
    Add-Table -Name 'Migrations' -Description 'some table''s description' -Column {
        int 'ID' -Identity
        bigint 'BigID' -NotNull -Description 'some bigint column''s description'
        nvarchar 'Name' -Size 241 -NotNull
        varchar 'NameMax' -Max
        datetime2 'AtUtc' -NotNull
        datetime2 'AtUtcCustomScale' -Scale 2
        datetimeoffset 'DTO' -NotNull
        datetimeoffset 'DTOwScale' -Scale 3
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
        New-Column -DataType 'CID' -Name 'CID' -NotNull
        varbinary 'VarBinDefault' -Size 1
        varbinary 'VarBinLargest' -Size 8000
        varbinary 'VarBinCustom' -Size 101
        varbinary 'VarBinMax' -Max
        binary 'BinOne' -Size 1
        binary 'BinSixteen' -Size 16
        time 'DefaultTime'
        time 'CustomTime' -Scale 5
        xml 'DefaultXml'
        varchar 'ExplicitMaxSize' -Size 8000
    }
    Add-PrimaryKey -TableName 'Migrations' -ColumnName 'ID'
    Add-DefaultConstraint -TableName 'Migrations' -ColumnName 'AtUtc' -Expression '(getutcdate())'
    Add-CheckConstraint -TableName 'Migrations' -Name 'CK_Migrations_Name' -Expression '([Name] = ''Fubar'')'
    Add-CheckConstraint -TableName 'Migrations' -Name 'CK_Migrations_Name2' -Expression '([Name] = ''Snafu'')' -NotForReplication -NoCheck
    Add-Index -TableName 'Migrations' -ColumnName 'BigID'
    Add-UniqueKey -TableName 'Migrations' -ColumnName 'Korean'
    Add-Trigger -Name 'MigrationsTrigger' -Definition 'ON [dbo].[Migrations] for insert as select 1'
}

function Pop-Migration
{
    Remove-Table 'Migrations'
    Remove-DataType 'CID'
}
'@
    Invoke-RTRivet -Push -Database $RTDatabaseName
    WhenCheckpointingMigration
    ThenSchemaFileRunnable
    ThenMigration -Not -HasContent 'Add-Schema -Name ''dbo''' -Database $RTDatabaseName
    ThenMigration -HasContent @'
    Add-Table -Name 'Migrations' -Description 'some table''s description' -Column {
        int 'ID' -Identity
        bigint 'BigID' -NotNull -Description 'some bigint column''s description'
        nvarchar 'Name' -Size 241 -NotNull
        varchar 'NameMax' -Max
        datetime2 'AtUtc' -NotNull
        datetime2 'AtUtcCustomScale' -Scale 2
        datetimeoffset 'DTO' -NotNull
        datetimeoffset 'DTOwScale' -Scale 3
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
        New-Column -DataType 'CID' -Name 'CID' -NotNull
        varbinary 'VarBinDefault' -Size 1
        varbinary 'VarBinLargest' -Size 8000
        varbinary 'VarBinCustom' -Size 101
        varbinary 'VarBinMax' -Max
        binary 'BinOne' -Size 1
        binary 'BinSixteen' -Size 16
        time 'DefaultTime'
        time 'CustomTime' -Scale 5
        xml 'DefaultXml'
        varchar 'ExplicitMaxSize' -Size 8000
    }
'@ -Database $RTDatabaseName
    ThenMigration -HasContent @'
    Add-PrimaryKey -TableName 'Migrations' -ColumnName 'ID' -Name 'PK_Migrations'
'@ -Database $RTDatabaseName
    ThenMigration -HasContent @'
    Add-DefaultConstraint -TableName 'Migrations' -ColumnName 'AtUtc' -Name 'DF_Migrations_AtUtc' -Expression '(getutcdate())'
'@ -Database $RTDatabaseName
    ThenMigration -HasContent @'
    Add-CheckConstraint -TableName 'Migrations' -Name 'CK_Migrations_Name' -Expression '([Name]=''Fubar'')'
'@ -Database $RTDatabaseName
    ThenMigration -HasContent 'Add-CheckConstraint -TableName ''Migrations'' -Name ''CK_Migrations_Name2'' -Expression ''([Name]=''''Snafu'''')'' -NotForReplication -NoCheck' -Database $RTDatabaseName
    ThenMigration -HasContent 'Add-Index -TableName ''Migrations'' -ColumnName ''BigID'' -Name ''IX_Migrations_BigID''' -Database $RTDatabaseName
    ThenMigration -HasContent 'Add-UniqueKey -TableName ''Migrations'' -ColumnName ''Korean'' -Name ''AK_Migrations_Korean''' -Database $RTDatabaseName
    ThenMigration -HasContent 'Add-Trigger -Name ''MigrationsTrigger'' -Definition @''
ON [dbo].[Migrations] for insert as select 1
''@' -Database $RTDatabaseName
    
    ThenMigration -HasContent 'Remove-Table -Name ''Migrations''' -Database $RTDatabaseName
    ThenMigration -Not -HasContent 'Remove-Schema' -Database $RTDatabaseName
    ThenMigration -Not -HasContent 'Remove-PrimaryKey' -Database $RTDatabaseName
    ThenMigration -Not -HasContent 'Remove-DefaultConstraint' -Database $RTDatabaseName
    ThenMigration -Not -HasContent 'Remove-CheckConstraint' -Database $RTDatabaseName
    ThenMigration -Not -HasContent 'Remove-Index' -Database $RTDatabaseName
    ThenMigration -Not -HasContent 'Remove-UniqueKey' -Database $RTDatabaseName
    ThenMigration -Not -HasContent 'Remove-Trigger' -Database $RTDatabaseName
    ThenNoErrors
    Reset
}

Describe 'Checkpoint-Migration.when there are multiple migrations but only one has been pushed' {
    Init
    GivenMigrationContent @'
function Push-Migration
{
    Add-Table -Name 'Test1' -Column {
        int 'ID' -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'Test1'
}
'@
    Invoke-RTRivet -Push -Database $RTDatabaseName
    GivenMigrationContent @'
function Push-Migration
{
    Add-Table -Name 'Test2' -Column {
        int 'ID' -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'Test2'
}
'@
    WhenCheckpointingMigration -Exclude $script:migrationPaths[1]
    ThenSchemaFileRunnable
    ThenMigration -HasContent @'
    Add-Table -Name 'Test1' -Column {
        int 'ID' -Identity
    }
'@ -Database $RTDatabaseName
    ThenMigration -Not -HasContent @'
    Add-Table -Name 'Test2' -Column {
        int 'ID' -Identity
    }
'@ -Database $RTDatabaseName
    ThenNoErrors
    Reset
}

Describe 'Checkpoint-Migration.when no migrations have been pushed' {
    Init
    # Nothing to push here. Just running push here to initialize database with rivet.migrations table.
    Invoke-RTRivet -Push -Database $RTDatabaseName
    WhenCheckpointingMigration
    ThenNoErrors
}