#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

$checkpointedMigrations = [System.Collections.ArrayList]::new()
$originalMigration = $null
$defaultOutputPath = $null

function Init
{
    $Global:Error.Clear()
    $script:checkpointedMigrations = [System.Collections.ArrayList]::new()
    $script:originalMigration = $null
    $script:defaultOutputPath = $null
}

function GivenMigrationContent
{
    param(
        [Parameter(Mandatory)]
        [String] $Content
    )

    $script:originalMigration = $Content
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
        [String] $HasContent
    )

    foreach( $migration in $checkpointedMigrations )
    {
        It ('should checkpoint migration') {
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
}

function WhenCheckpointingMigration
{
    [CmdletBinding()]
    param(
        [String[]] $Database,

        [String] $OutputPath,

        [Switch] $Force
    )

    Start-RivetTest
    try
    {
        if(-not $Database )
        {
            $Database = $RTDatabaseName
        }

        $migrationPath = [System.Collections.ArrayList]::new()

        foreach( $databaseName in $Database )
        {
            $path = $originalMigration | New-TestMigration -Name 'CheckpointMigration' -DatabaseName $databaseName
            $migrationPath.Add($path)
        }

        if( -not $script:defaultOutputPath)
        {
            $script:defaultOutputPath = Join-Path -Path (Get-ChildItem -Path $TestDrive).FullName -ChildPath 'schema.ps1'
        }

        Invoke-RTRivet -Checkpoint -Database $Database -CheckpointOutputPath $OutputPath -Force:$Force -ErrorAction SilentlyContinue

        if( -not $OutputPath )
        {
            $OutputPath = $defaultOutputPath
        }

        foreach( $path in $migrationPath )
        {
            $databaseName = $path.Directory.Parent.Name
            $checkpointedMigration = Get-Content -Path $OutputPath
            $script:checkpointedMigrations.Add($checkpointedMigration)
            It ('should export a runnable migration') {
                # Now, check that the migration is runnable
                Invoke-RTRivet -Pop -Database $databaseName

                $checkpointedMigration | Set-Content -Path $path
                Invoke-RTRivet -Push -Database $databaseName -ErrorAction Stop
                Invoke-RTRivet -Pop -Force -Database $databaseName -ErrorAction Stop
            }
        }
    }
    finally
    {
        Stop-RivetTest
    }
}

Describe 'Checkpoint-Migration.when there are multiple databases' {
    Init
    GivenMigrationContent @'
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
'@
    WhenCheckpointingMigration -Database ('RivetTest', 'RivetTest2')
    ThenMigration -HasContent @'
    Add-Table -Name 'Replicated' -Column {
        int 'ID' -Identity
    }
'@
    ThenMigration -HasContent @'
    Add-Table -Name 'NotReplicated' -Column {
        int 'ID' -Identity -NotForReplication
    }
'@
    ThenNoErrors
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
    WhenCheckpointingMigration
    ThenMigration -HasContent @'
    Add-Table -Name 'NotReplicated' -Column {
        int 'ID' -Identity -NotForReplication
    }
'@

    GivenMigrationContent @'
function Push-Migration
{
    Add-Table -Name 'Replicated' -Column {
        int 'ID' -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'Replicated'
}
'@
    WhenCheckpointingMigration -OutputPath $defaultOutputPath
    ThenFailed -WithError 'schema.ps1" already exists.'
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
    WhenCheckpointingMigration
    ThenMigration -HasContent @'
    Add-Table -Name 'NotReplicated' -Column {
        int 'ID' -Identity -NotForReplication
    }
'@

    GivenMigrationContent @'
function Push-Migration
{
    Add-Table -Name 'Replicated' -Column {
        int 'ID' -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'Replicated'
}
'@
    WhenCheckpointingMigration -OutputPath $defaultOutputPath -Force
    ThenNoErrors
}

Describe 'Checkpoint-Migration.when given custom output path' {
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
    WhenCheckpointingMigration -OutputPath (Join-Path -Path $TestDrive.FullName -ChildPath 'schema.ps1')
    ThenMigration -HasContent @'
    Add-Table -Name 'NotReplicated' -Column {
        int 'ID' -Identity -NotForReplication
    }
'@
    ThenNoErrors
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
    WhenCheckpointingMigration
    ThenMigration -Not -HasContent 'Add-Schema -Name ''dbo'''
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
    ThenMigration -HasContent 'Add-CheckConstraint -TableName ''Migrations'' -Name ''CK_Migrations_Name2'' -Expression ''([Name]=''''Snafu'''')'' -NotForReplication -NoCheck'
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
    ThenNoErrors
}
