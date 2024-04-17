
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:checkpointedMigrations = [System.Collections.ArrayList]::new()
    $script:migrationPaths = [System.Collections.ArrayList]::new()
    $script:database = [System.Collections.ArrayList]::new()
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

    function GivenMigrationContent
    {
        param(
            [Parameter(Mandatory)]
            [String] $Content,

            [String[]] $Database,

            [String] $Name
        )

        if(-not $Database )
        {
            $Database = $RTDatabaseName
        }

        foreach( $databaseName in $Database )
        {
            $path = $Content | New-TestMigration -Name $Name -DatabaseName $databaseName
            $script:migrationPaths.Add($path)
        }
    }

    function Reset
    {
        param(
        )

        $database = $script:database
        if( -not $database )
        {
            $database = $RTDatabaseName
        }

        foreach( $databaseItem in $database )
        {
            Remove-RivetTestDatabase -Name $databaseItem
        }
    }

    function ThenFailed
    {
        param(
            [String] $WithError
        )

        $Global:Error | Should -Match $WithError
    }

    function ThenNoErrors
    {
        $Global:Error | Should -BeNullOrEmpty
    }

    function ThenSchema
    {
        param(
            [Switch] $Not,

            [Parameter(Mandatory)]
            [String] $HasContent,

            [Parameter(Mandatory)]
            [String[]] $Database,

            [String[]] $ContainsRowsFor
        )

        foreach( $databaseItem in $Database )
        {
            $migration = $script:checkpointedMigrations | Where-Object {$_.Database -eq $databaseItem}

            if( $Not )
            {
                ($migration.Migration -join [Environment]::NewLine) | Should -Not -BeLike ('*{0}*' -f [wildcardpattern]::Escape($HasContent))
            }
            else
            {
                ($migration.Migration -join [Environment]::NewLine) | Should -BeLike ('*{0}*' -f [wildcardpattern]::Escape($HasContent))
            }

            foreach( $row in $ContainsRowsFor )
            {
                ($migration.Migration -join [Environment]::NewLine) | Should -BeLike ('*{0}*' -f [wildcardpattern]::Escape($row))
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

            Remove-RivetTestDatabase -Name $databaseName
            # Now, check that the schema.ps1 script is runnable
            Invoke-RTRivet -Push -Database $databaseName -ErrorAction Stop
            Invoke-RTRivet -Pop -Database $databaseName -ErrorAction Stop
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
}

Describe 'Checkpoint-Migration' {
    BeforeEach {
        $Global:Error.Clear()
        $script:checkpointedMigrations = [System.Collections.ArrayList]::new()
        $script:migrationPaths = [System.Collections.ArrayList]::new()
        $script:database = [System.Collections.ArrayList]::new()
        Start-RivetTest
    }

    AfterEach {
        Reset
    }

    It 'should successfuly checkpoint migrations when there are multiple databases' {
        $script:database = 'RivetTest', 'RivetTest2'
        GivenMigrationContent -Name 'CheckpointMigration' -Content @'
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
'@ -Database ($script:database)
        Invoke-RTRivet -Push -Database ($script:database)
        WhenCheckpointingMigration -Database ($script:database)
        ThenSchemaFileRunnable
        ThenSchema -HasContent @'
    Add-Table -Name 'Replicated' -Column {
        int 'ID' -Identity
    }
'@ -Database ($script:database)
        ThenSchema -HasContent @'
    Add-Table -Name 'NotReplicated' -Column {
        int 'ID' -Identity -NotForReplication
    }
'@ -Database ($script:database)
        ThenSchema -HasContent @'
    Add-Row -SchemaName 'rivet' -TableName 'Migrations' -Column @{
'@ -ContainsRowsFor 'CheckpointMigration' -Database ($script:database)
        ThenNoErrors
    }

    It 'should fail when schema.ps1 file already exists' {
        GivenMigrationContent -Name 'CheckpointMigration' -Content @'
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
    }

    It 'should overwrite contents when schema.ps1 file already exists but -Force switch is given' {
        GivenMigrationContent -Name 'CheckpointMigration' -Content @'
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
        ThenSchema -HasContent @'
    Add-Table -Name 'NotReplicated' -Column {
        int 'ID' -Identity -NotForReplication
    }
'@ -Database $RTDatabaseName
        ThenSchema -HasContent @'
    Add-Row -SchemaName 'rivet' -TableName 'Migrations' -Column @{
'@ -ContainsRowsFor 'CheckpointMigration' -Database $RTDatabaseName
        ThenNoErrors
    }

    It 'should pass when checkpointing a migration' {
        GivenMigrationContent -Name 'CheckpointMigration' -Content @'
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
        ThenSchema -Not -HasContent 'Add-Schema -Name ''dbo''' -Database $RTDatabaseName
        ThenSchema -HasContent @'
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
        ThenSchema -HasContent @'
    Add-PrimaryKey -TableName 'Migrations' -ColumnName 'ID' -Name 'PK_Migrations'
'@ -Database $RTDatabaseName
        ThenSchema -HasContent @'
    Add-DefaultConstraint -TableName 'Migrations' -ColumnName 'AtUtc' -Name 'DF_Migrations_AtUtc' -Expression '(getutcdate())'
'@ -Database $RTDatabaseName
        ThenSchema -HasContent @'
    Add-CheckConstraint -TableName 'Migrations' -Name 'CK_Migrations_Name' -Expression '([Name]=''Fubar'')'
'@ -Database $RTDatabaseName
        ThenSchema -HasContent 'Add-CheckConstraint -TableName ''Migrations'' -Name ''CK_Migrations_Name2'' -Expression ''([Name]=''''Snafu'''')'' -NotForReplication -NoCheck' -Database $RTDatabaseName
        ThenSchema -HasContent 'Add-Index -TableName ''Migrations'' -ColumnName ''BigID'' -Name ''IX_Migrations_BigID''' -Database $RTDatabaseName
        ThenSchema -HasContent 'Add-UniqueKey -TableName ''Migrations'' -ColumnName ''Korean'' -Name ''AK_Migrations_Korean''' -Database $RTDatabaseName
        ThenSchema -HasContent 'Add-Trigger -Name ''MigrationsTrigger'' -Definition @''
ON [dbo].[Migrations] for insert as select 1
''@' -Database $RTDatabaseName
        ThenSchema -HasContent @'
    Add-Row -SchemaName 'rivet' -TableName 'Migrations' -Column @{
'@ -ContainsRowsFor 'CheckpointMigration' -Database $RTDatabaseName

        ThenSchema -HasContent 'Remove-Table -Name ''Migrations''' -Database $RTDatabaseName
        ThenSchema -Not -HasContent 'Remove-Schema' -Database $RTDatabaseName
        ThenSchema -Not -HasContent 'Remove-PrimaryKey' -Database $RTDatabaseName
        ThenSchema -Not -HasContent 'Remove-DefaultConstraint' -Database $RTDatabaseName
        ThenSchema -Not -HasContent 'Remove-CheckConstraint' -Database $RTDatabaseName
        ThenSchema -Not -HasContent 'Remove-Index' -Database $RTDatabaseName
        ThenSchema -Not -HasContent 'Remove-UniqueKey' -Database $RTDatabaseName
        ThenSchema -Not -HasContent 'Remove-Trigger' -Database $RTDatabaseName
        ThenNoErrors
    }

    It 'should only checkpoint pushed migrations when there are multiple migrations but only one has been pushed' {
        GivenMigrationContent -Name 'CheckpointMigration' -Content @'
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
        GivenMigrationContent -Name 'CheckpointMigration2' -Content @'
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
        ThenSchema -HasContent @'
    Add-Table -Name 'Test1' -Column {
        int 'ID' -Identity
    }
'@ -Database $RTDatabaseName
        ThenSchema -Not -HasContent @'
    Add-Table -Name 'Test2' -Column {
        int 'ID' -Identity
    }
'@ -Database $RTDatabaseName
        ThenSchema -HasContent @'
    Add-Row -SchemaName 'rivet' -TableName 'Migrations' -Column @{
'@ -ContainsRowsFor 'CheckpointMigration' -Database $RTDatabaseName
        ThenNoErrors
    }

    It 'should only checkpoint all migrations when multiple migrations have been pushed' {
        GivenMigrationContent -Name 'CheckpointMigration' -Content @'
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
        GivenMigrationContent -Name 'CheckpointMigration2' -Content @'
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
        Invoke-RTRivet -Push -Database $RTDatabaseName
        WhenCheckpointingMigration -Exclude $script:migrationPaths[1]
        ThenSchemaFileRunnable
        ThenSchema -HasContent @'
    Add-Table -Name 'Test1' -Column {
        int 'ID' -Identity
    }
'@ -Database $RTDatabaseName
        ThenSchema -HasContent @'
    Add-Table -Name 'Test2' -Column {
        int 'ID' -Identity
    }
'@ -Database $RTDatabaseName
        ThenSchema -HasContent @'
    Add-Row -SchemaName 'rivet' -TableName 'Migrations' -Column @{
'@ -ContainsRowsFor 'CheckpointMigration', 'CheckpointMigration2' -Database $RTDatabaseName
        ThenNoErrors
    }

    It 'should do nothing when no migrations have been pushed' {
        # Nothing to push here. Just running push here to initialize database with rivet.migrations table.
        Invoke-RTRivet -Push -Database $RTDatabaseName
        WhenCheckpointingMigration
        ThenNoErrors
    }
}