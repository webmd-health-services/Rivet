#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:migration = $null
    $script:originalMigration = $null

    function GivenDatabase
    {
        param(
            [Parameter(Mandatory)]
            [String[]] $Name
        )

        $script:databases += $Name
    }

    function GivenMigrationContent
    {
        param(
            [Parameter(Mandatory)]
            [String] $Content
        )

        $script:originalMigration = $Content
    }

    function ThenNoErrors
    {
        $Global:Error | Should -BeNullOrEmpty
    }

    function ThenMigration
    {
        param(
            [Switch] $Not,

            [Parameter(Mandatory)]
            [String] $HasContent
        )

        if( $Not )
        {
            ($script:migration -join [Environment]::NewLine) | Should -Not -BeLike ('*{0}*' -f [wildcardpattern]::Escape($HasContent))
        }
        else
        {
            ($script:migration -join [Environment]::NewLine) | Should -BeLike ('*{0}*' -f [wildcardpattern]::Escape($HasContent))
        }
    }

    function WhenExporting
    {
        [CmdletBinding()]
        param(
            [String[]] $Include,

            [Switch] $SkipVerification,

            [String[]] $ExcludeType,

            [String[]] $Exclude,

            [String] $Database
        )

        if( -not $Database )
        {
            $Database = $RTDatabaseName
        }

        Start-RivetTest -DatabaseName $Database
        try
        {
            $testDirectory = Get-ChildItem -Path $TestDrive | Sort-Object -Property LastWriteTime | Select-Object -Last 1
            $configFilePath = Join-Path -Path $testDirectory.FullName -ChildPath 'rivet.json'

            $script:migrationPath = ''
            if( $script:originalMigration )
            {
                $script:migrationPath =
                    $script:originalMigration |
                    New-TestMigration -Name 'ExportMigration' -DatabaseName $Database -ConfigFilePath $configFilePath
            }

            Invoke-RTRivet -Push -ConfigFilePath $configFilePath -Database $Database
            $optionalParams = @{}
            if( $PSBoundParameters.ContainsKey('Include') )
            {
                $optionalParams['Include'] = $Include
            }

            if( $PSBoundParameters.ContainsKey('ExcludeType') )
            {
                $optionalParams['ExcludeType'] = $ExcludeType
            }

            if( $PSBoundParameters.ContainsKey('Exclude') )
            {
                $optionalParams['Exclude'] = $Exclude
            }

            $Global:Error.Clear()

            $script:migration = Export-Migration -SqlServerName $RTServer -Database $Database -ConfigFilePath $configFilePath @optionalParams
            Write-Debug -Message ($script:migration -join [Environment]::NewLine)

            if( -not $SkipVerification )
            {
                # Now, check that the migration is runnable
                Invoke-RTRivet -Pop

                $script:migration | Set-Content -Path $script:migrationPath
                Invoke-RTRivet -Push -ErrorAction Stop
                Invoke-RTRivet -Pop -ErrorAction Stop
            }
        }
        finally
        {
            Stop-RivetTest -DatabaseName $Database
        }
    }
}

Describe 'Export-Migration' {
    BeforeEach {
        $script:migration = $null
        $script:originalMigration = $null
    }

    It 'exports a table' {
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
        WhenExporting
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
    }

    It 'exports identity column that is not for replication' {
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
        WhenExporting
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
    }

    It 'exports table that has a custom data type as its identity' {
        GivenMigrationContent @'
function Push-Migration
{
    Add-DataType -Name 'SID' -From 'int'
    Add-Table -Name 'Migrations' -Description 'some table''s description' -Column {
        New-Column 'SidColumn' 'SID' -Identity -Seed 300000000 -Increment 1 -NotForReplication
    }
    Add-PrimaryKey -TableName 'Migrations' -ColumnName 'SidColumn'
}

function Pop-Migration
{
    Remove-Table 'Migrations'
    Remove-DataType 'SID'
}
'@
        WhenExporting
        ThenMigration -HasContent @'
    Add-DataType -Name 'SID' -From 'int'
    Add-Table -Name 'Migrations' -Description 'some table''s description' -Column {
        New-Column -DataType 'SID' -Name 'SidColumn' -Identity -Seed 300000000 -Increment 1 -NotForReplication
    }
    Add-PrimaryKey -TableName 'Migrations' -ColumnName 'SidColumn'
'@
    }

    It 'exports XML column that has a schema' {
        GivenMigrationContent @'
function Push-Migration
{
    Invoke-Ddl -Query '
    create xml schema collection EmptyXsd as
    N''
    <xsd:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions"
       xmlns          ="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions"
       elementFormDefault="qualified"
       attributeFormDefault="unqualified"
       xmlns:xsd="http://www.w3.org/2001/XMLSchema" >

        <xsd:element  name="root" />

    </xsd:schema>
    ''
'

    Add-Table -Name 'Xml' -Column {
        xml 'Content' -XmlSchemaCollection 'EmptyXsd'
        Xml 'Document' -Document -XmlSchemaCollection 'EmptyXsd'
    }
}

function Pop-Migration
{
    Remove-Table 'Xml'
    Invoke-Ddl 'drop xml schema collection EmptyXsd'
}
'@
        WhenExporting
        ThenMigration -HasContent @'
    Add-Table -Name 'Xml' -Column {
        xml 'Content' -XmlSchemaCollection 'EmptyXsd'
        Xml 'Document' -Document -XmlSchemaCollection 'EmptyXsd'
    }
'@
        ThenMigration -HasContent 'create xml schema collection [dbo].[EmptyXsd]'
        ThenMigration -HasContent 'drop xml schema collection [dbo].[EmptyXsd]'
    }

    It 'exports objects with wildcards' {
        GivenMigrationContent @'
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

    It 'exports default constraints' {
        GivenMigrationContent @'
function Push-Migration
{
    Add-Table 'Fubar' {
        int 'ID'
        char 'YN' -Size 1
    }
    Add-DefaultConstraint -TableName 'Fubar' -ColumnName 'ID' -Expression '1'
    Add-DefaultConstraint -TableName 'Fubar' -ColumnName 'YN' -Expression '''N'''

    # Make sure default constraints on table-valued functions don't get exported.
    Add-UserDefinedFunction -Name 'HasDefaultConstraint' -Definition '
(
)
    RETURNS		@Table		TABLE
	(
	    [Status] [int] NOT NULL DEFAULT (0)
	)
as
begin
    insert into @Table select 1
	return
end
'
}

function Pop-Migration
{
    Remove-UserDefinedFunction 'HasDefaultConstraint'
    Remove-Table 'Fubar'
}
'@
        WhenExporting 'dbo.DF_Fubar_*','dbo.DF__*' -SkipVerification
        ThenMigration -HasContent 'Add-DefaultConstraint -TableName ''Fubar'' -ColumnName ''ID'' -Name ''DF_Fubar_ID'' -Expression ''((1))'''
        ThenMigration -HasContent 'Add-DefaultConstraint -TableName ''Fubar'' -ColumnName ''YN'' -Name ''DF_Fubar_YN'' -Expression ''(''''N'''')'''
        ThenMigration -HasContent 'Remove-DefaultConstraint -TableName ''Fubar'' -Name ''DF_Fubar_ID'''
        ThenMigration -Not -HasContent 'DF__'
    }

    It 'exports a primary key' {
        GivenMigrationContent @'
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

    It 'exports a non-clustered primary key' {
        GivenMigrationContent @'
function Push-Migration
{
    Add-Table 'Fubar' {
        int 'ID' -NotNull
    }
    Add-PrimaryKey -TableName 'Fubar' -ColumnName 'ID' -NonClustered
}

function Pop-Migration
{
    Remove-Table 'Fubar'
}
'@
        WhenExporting
        ThenMigration -HasContent 'Add-PrimaryKey -TableName ''Fubar'' -ColumnName ''ID'' -Name ''PK_Fubar'' -NonClustered'
        ThenMigration -HasContent 'Remove-Table -Name ''Fubar'''
        ThenMigration -Not -HasContent 'Remove-PrimaryKey'
    }

    It 'exports check constraints' {
        GivenMigrationContent @'
function Push-Migration
{
    Add-Table 'CheckConstraint' {
        int ID
        char 'YN' -Size 1
        int LessThan10
    }
    Add-CheckConstraint -TableName 'CheckConstraint' -Name 'CK_CheckConstraint_ID' -Expression '[ID] > 0 and [ID] < 10'
    Add-CheckConstraint -TableName 'CheckConstraint' -Name 'CK_CheckConstraint_YN' -Expression '[YN] = ''Y'' or [YN] = ''N''' -NoCheck
    Add-CheckConstraint -TableName 'CheckConstraint' -Name 'CK_CheckConstraint_ID_LessThan10' -Expression '[LessThan10] < 10'
    Disable-Constraint -TableName 'CheckConstraint' -Name 'CK_CheckConstraint_ID_LessThan10'
}

function Pop-Migration
{
    Remove-Table 'CheckConstraint'
}
'@
        WhenExporting 'dbo.CK_CheckConstraint_*' -SkipVerification
        ThenMigration -HasContent 'Add-CheckConstraint -TableName ''CheckConstraint'' -Name ''CK_CheckConstraint_ID'' -Expression ''([ID]>(0) AND [ID]<(10))'''
        ThenMigration -HasContent 'Add-CheckConstraint -TableName ''CheckConstraint'' -Name ''CK_CheckConstraint_YN'' -Expression ''([YN]=''''Y'''' OR [YN]=''''N'''')'' -NoCheck'
        ThenMigration -HasContent 'Add-CheckConstraint -TableName ''CheckConstraint'' -Name ''CK_CheckConstraint_ID_LessThan10'' -Expression ''([LessThan10]<(10))'''
        ThenMigration -HasContent 'Disable-Constraint -TableName ''CheckConstraint'' -Name ''CK_CheckConstraint_ID_LessThan10'''
        ThenMigration -HasContent 'Remove-CheckConstraint -TableName ''CheckConstraint'' -Name ''CK_CheckConstraint_ID'''
        ThenMigration -Not -HasContent 'Add-Table'
    }

    It 'exports a stored procedure' {
        GivenMigrationContent @'
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

    It 'exports a stored procedure not added with Rivet' {
        GivenMigrationContent @'
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

    It 'exports a view' {
        GivenMigrationContent @'
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

    It 'exports a view not added with Rivet' {
        GivenMigrationContent @'
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

    It 'exports a function' {
        GivenMigrationContent @'
function Push-Migration
{
    Add-UserDefinedFunction -Name 'CallSomething' -Definition '() returns tinyint as begin return 1 end'
    Add-UserDefinedFunction -Name 'CallInlineTable' -Definition '() returns table as return( select 1 as name )'
    Add-UserDefinedFunction -Name 'CallTable' -Definition '() returns @Table TABLE ( ID int primary key ) as begin insert into @Table select 1 return end'
}

function Pop-Migration
{
    Remove-UserDefinedFunction -Name 'CallTable'
    Remove-UserDefinedFunction -Name 'CallInlineTable'
    Remove-UserDefinedFunction -Name 'CallSomething'
}
'@
        WhenExporting 'dbo.Call*','*.PK*'
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
() returns @Table TABLE ( ID int primary key ) as begin insert into @Table select 1 return end
'@
"@
        ThenMigration -HasContent 'Remove-UserDefinedFunction -Name ''CallSomething'''
        ThenMigration -HasContent 'Remove-UserDefinedFunction -Name ''CallInlineTable'''
        ThenMigration -HasContent 'Remove-UserDefinedFunction -Name ''CallTable'''
        ThenMigration -Not -HasContent 'Add-PrimaryKey'
    }

    It 'exports a function not added with Rivet' {
        GivenMigrationContent @'
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

    It 'exports entire database' {
        WhenExporting -SkipVerification
        ThenMigration -Not -HasContent 'rivet'
        ThenNoErrors
    }

    It 'exports data type' {
        GivenMigrationContent @'
function Push-Migration
{
    Add-Schema 'export'
    Add-DataType 'GUID' 'uniqueidentifier'
    Add-DataType 'SID' 'int'
    Add-DataType 'CID' 'char(8)'
    Add-DataType 'mymoney' 'decimal(20,2) not null'
    Add-DataType 'lotsa' 'varchar(max)'
    Add-DataType -SchemaName 'export' 'GUID2' 'uniqueidentifier'
    Add-DataType 'TableType' -AsTable {
        uniqueidentifier 'uniqueID' -NotNull
        smallint 'appID' -NotNull
        int 'statusID' -NotNull
    }
    Add-DataType -SchemaName 'export' 'TableType2' -AsTable {
        uniqueidentifier 'uniqueID2'
        smallint 'appID2'
        int 'statusID2'
    }
}
function Pop-Migration
{
    Remove-DataType -SchemaName 'export' 'TableType2'
    Remove-DataType 'TableType'
    Remove-DataType -SchemaName 'export' 'GUID2'
    Remove-DataType 'lotsa'
    Remove-DataType 'mymoney'
    Remove-DataType 'CID'
    Remove-DataType 'SID'
    Remove-Datatype 'GUID'
    Remove-Schema 'export'
}
'@
        WhenExporting
        ThenMigration -HasContent 'Add-DataType -Name ''GUID'' -From ''uniqueidentifier'''
        ThenMigration -HasContent 'Add-DataType -Name ''SID'' -From ''int'''
        ThenMigration -HasContent 'Add-DataType -Name ''CID'' -From ''char(8)'''
        ThenMigration -HasContent 'Add-DataType -Name ''mymoney'' -From ''decimal(20,2) not null'''
        ThenMigration -HasContent 'Add-DataType -Name ''lotsa'' -From ''varchar(max)'''
        ThenMigration -HasContent 'Add-DataType -SchemaName ''export'' -Name ''GUID2'' -From ''uniqueidentifier'''
        ThenMigration -HasContent 'Add-Schema -Name ''export'
        ThenMigration -HasContent 'Remove-DataType -Name ''GUID'''
        ThenMigration -HasContent 'Remove-DataType -SchemaName ''export'' -Name ''GUID2'''
        ThenMigration -HasContent 'Remove-Schema -Name ''export'''
        ThenMigration -HasContent @'
    Add-DataType -Name 'TableType' -AsTable {
        uniqueidentifier 'uniqueID' -NotNull
        smallint 'appID' -NotNull
        int 'statusID' -NotNull
    }
'@
        ThenMigration -HasContent @'
    Add-DataType -SchemaName 'export' -Name 'TableType2' -AsTable {
        uniqueidentifier 'uniqueID2'
        smallint 'appID2'
        int 'statusID2'
    }
'@
    }

    It 'exports filtered data type' {
        GivenMigrationContent @'
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
        ThenMigration -Not -HasContent 'Remove-Schema -Name ''export'''
    }

    It 'exports identity that has custom seed and increment' {
        GivenMigrationContent @'
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

    It 'exports indexes' {
        GivenMigrationContent @'
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

    Add-Table -Name 'IndexesWithInclude' -Column {
        int ID -NotNull
        int ID2 -NotNull
        int ID3 -NotNull
        int ID4 -NotNull
        int ID5 -NotNull
        int ID6 -NotNull
    }
    Add-Index -TableName 'IndexesWithInclude' -ColumnName 'ID' -Include 'ID6','ID5','ID4'

    Add-Table -Name 'IndexesWithDescending' -Column {
        int ID -NotNull
        int ID2 -NotNull
        int ID3 -NotNull
        int ID4 -NotNull
        int ID5 -NotNull
        int ID6 -NotNull
    }
    Add-Index -TableName 'IndexesWithDescending' -ColumnName 'ID','ID2','ID3' -Descending $true,$false,$true

    Add-Schema -Name 'export'
    Add-Table -SchemaName 'export' -Name 'Indexes2' -Column {
        int ID
    }
    Add-Index -SchemaName 'export' -TableName 'Indexes2' -ColumnName 'ID'
}
function Pop-Migration
{
    Remove-Table -SchemaName 'export' -Name 'Indexes2'
    Remove-Schema 'export'
    Remove-Table 'IndexesWithDescending'
    Remove-Table 'IndexesWithInclude'
    Remove-Table 'Indexes'
}
'@
        WhenExporting '*.*_Indexes*' -SkipVerification
        ThenMigration -HasContent 'Add-Index -TableName ''Indexes'' -ColumnName ''ID'' -Name ''IX_Indexes_ID'''
        ThenMigration -HasContent 'Add-Index -TableName ''Indexes'' -Columnname ''ID2'',''ID3'' -Name ''IX_Indexes_ID2_ID3'''
        ThenMigration -HasContent 'Add-Index -TableName ''Indexes'' -ColumnName ''ID4'' -Name ''UIX_Indexes_ID4'' -Unique'
        ThenMigration -HasContent 'Add-Index -TableName ''Indexes'' -ColumnName ''ID5'' -Name ''IX_Indexes_ID5'' -Clustered'
        ThenMigration -HasContent 'Add-Index -TableName ''Indexes'' -ColumnName ''ID6'' -Name ''IX_Indexes_ID6'' -Where ''([ID6]<=(100))'''
        ThenMigration -HasContent 'Add-Index -SchemaName ''export'' -TableName ''Indexes2'' -ColumnName ''ID'' -Name ''IX_export_Indexes2_ID'''
        ThenMigration -HasContent 'Add-Index -TableName ''IndexesWithInclude'' -ColumnName ''ID'' -Name ''IX_IndexesWithInclude_ID'' -Include ''ID4'',''ID5'',''ID6'''
        ThenMigration -HasContent 'Add-Index -TableName ''IndexesWithDescending'' -ColumnName ''ID'',''ID2'',''ID3'' -Name ''IX_IndexesWithDescending_ID_ID2_ID3'' -Descending $true,$false,$true'
        ThenMigration -Not -HasContent 'Add-Index -SchemaName ''export'' -TableName ''Indexes2'' -ColumnName '''' -Name '''''

        ThenMigration -HasContent 'Remove-Index -TableName ''Indexes'' -Name ''IX_Indexes_ID'''
        ThenMigration -HasContent 'Remove-Index -TableName ''Indexes'' -Name ''IX_Indexes_ID2_ID3'''
        ThenMigration -HasContent 'Remove-Index -TableName ''Indexes'' -Name ''UIX_Indexes_ID4'''
        ThenMigration -HasContent 'Remove-Index -TableName ''Indexes'' -Name ''IX_Indexes_ID5'''
        ThenMigration -HasContent 'Remove-Index -TableName ''Indexes'' -Name ''IX_Indexes_ID6'''
        ThenMigration -HasContent 'Remove-Index -SchemaName ''export'' -TableName ''Indexes2'' -Name ''IX_export_Indexes2_ID'''
    }

    It 'exports unique keys' {
        GivenMigrationContent @'
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

    It 'exports triggers' {
        GivenMigrationContent @'
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

    It 'exports synonyms' {
        GivenMigrationContent @'
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

    It 'exports synonym that points to internal object' {
        GivenMigrationContent @'
function Push-Migration
{
    Add-Table -Name 'Target' {
        int 'ID' -NotNull
    }

    Add-Synonym -Name 'Syn1' -TargetObjectName 'Target'

    # We remove and re-create so that the synonym gets exported before the table.
    Remove-Table 'Target'

    Add-Table -Name 'Target' {
        int 'ID' -NotNull
    }
}
function Pop-Migration
{
    Remove-Synonym 'Syn1'
    Remove-Table 'Target'
}
'@
        WhenExporting
        ThenMigration -HasContent @'
    Add-Table -Name 'Target' -Column {
        int 'ID' -NotNull
    }
    Add-Synonym -Name 'Syn1' -TargetSchemaName 'dbo' -TargetObjectName 'Target'
'@
    }

    It 'exports foreign keys' {
        GivenMigrationContent @'
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

    Disable-Constraint -TableName 'Table' -Name 'FK_Table_Table2'

    Add-Schema 'export'

    Add-Table -SchemaName 'export' 'Table3' {
        int 'Table3_ID' -NotNull
    }
    Add-PrimaryKey -SchemaName 'export' -TableName 'Table3' -ColumnName 'Table3_ID'

    Add-Table -SchemaName 'export' 'Table4' {
        int 'Table4_ID' -NotNull
    }
    Add-PrimaryKey -SchemaName 'export' -TableName 'Table4' -ColumnName 'Table4_ID'

    Add-ForeignKey -SchemaName 'export' -TableName 'Table3' -ColumnName 'Table3_ID' -ReferencesSchema 'export' -References 'Table4' -ReferencedColumn 'Table4_ID' -OnDelete 'CASCADE' -OnUpdate 'CASCADE' -NotForReplication
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
        ThenMigration -HasContent 'Disable-Constraint -TableName ''Table'' -Name ''FK_Table_Table2'''
        ThenMigration -Not -HasContent 'Disable-Constraint -SchemaName ''export'' -TableName ''Table3'''
    }

    It 'exports a table with a custom identity seed or increment' {
        GivenMigrationContent @'
function Push-Migration
{
    Add-Table -Name 'Seed' {
        int 'ID' -Identity -Seed 101 -Increment 1
    }
    Add-Table -Name 'Increment' {
        int 'ID2' -Identity -Seed 1 -Increment 101
    }
    Add-Table -Name 'Defaults' {
        int 'ID3' -Identity -Seed 1 -Increment 1
    }
}
function Pop-Migration
{
    Remove-Table -Name 'Defaults'
    Remove-Table -Name 'Increment'
    Remove-Table -Name 'Seed'
}
'@
        WhenExporting
        ThenMigration -HasContent 'int ''ID'' -Identity -Seed 101 -Increment 1'
        ThenMigration -HasContent 'int ''ID2'' -Identity -Seed 1 -Increment 101'
        ThenMigration -HasContent 'int ''ID3'' -Identity'
    }

    It 'exports a table with a custom identity seed or increment' {
        GivenMigrationContent @'
function Push-Migration
{
    Add-Table -Name 'Seed' {
        int 'ID' -Identity -Seed 101 -Increment 1
    }
    Add-Table -Name 'Increment' {
        int 'ID2' -Identity -Seed 1 -Increment 101
    }
    Add-Table -Name 'Defaults' {
        int 'ID3' -Identity -Seed 1 -Increment 1
    }
}
function Pop-Migration
{
    Remove-Table -Name 'Defaults'
    Remove-Table -Name 'Increment'
    Remove-Table -Name 'Seed'
}
'@
        WhenExporting
        ThenMigration -HasContent 'int ''ID'' -Identity -Seed 101 -Increment 1'
        ThenMigration -HasContent 'int ''ID2'' -Identity -Seed 1 -Increment 101'
        ThenMigration -HasContent 'int ''ID3'' -Identity'
    }

    It 'excludes objects by type' {
        GivenMigrationContent @'
function Push-Migration
{
    Invoke-Ddl -Query '
    create xml schema collection EmptyXsd as
    N''
    <xsd:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions"
       xmlns          ="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions"
       elementFormDefault="qualified"
       attributeFormDefault="unqualified"
       xmlns:xsd="http://www.w3.org/2001/XMLSchema" >

        <xsd:element  name="root" />

    </xsd:schema>
    ''
'

    Add-DataType 'SID' -From 'int'

    Add-Table -Name 'Xml' -Column {
        int 'ID' -NotNull
        xml 'Content' -XmlSchemaCollection 'EmptyXsd'
        Xml 'Document' -Document -XmlSchemaCollection 'EmptyXsd'
        New-Column -DataType 'SID' -Name 'AnotherID' -NotNull
    }
    Add-PrimaryKey -TableName 'Xml' -ColumnName 'ID'
    Add-CheckConstraint -TableName 'Xml' -Expression '[ID]<10' -Name 'CK_Xml_ID'
    Add-DefaultConstraint -TableName 'Xml' -ColumnName 'ID' -Expression '1'
    Add-Index -TableName 'Xml' -ColumnName 'AnotherID'

    Add-Table -Name 'Xml2' -Column {
        int 'ID' -NotNull
        int 'XmlID' -NotNull
    }
    Add-UniqueKey -TableName 'Xml2' -ColumnName 'ID'
    Add-ForeignKey -TableName 'Xml2' -ColumnName 'XmlID' -References 'Xml' -ReferencedColumn 'ID'

    Add-Schema -Name 'export'
    Add-UserDefinedFunction -SchemaName 'export' -Name 'CallSomething' -Definition '() returns tinyint as begin return 1 end'
    Add-UserDefinedFunction -Name 'CallInlineTable' -Definition '() returns table as return( select 1 as name )'
    Add-UserDefinedFunction -Name 'CallTable' -Definition '() returns @Table TABLE ( ID int primary key ) as begin insert into @Table select 1 return end'
    Add-StoredProcedure -Name 'DoSomething' -Definition 'as select 1'
    Add-Synonym -Name 'Xml3' -TargetObjectName 'Xml2'
    Add-Trigger -Name 'trgXml' -Definition 'ON [dbo].[Xml] for insert as select 1'
    Add-View -Name 'ViewSomething' -Definition 'as select 1 as one'
}

function Pop-Migration
{
    Remove-View 'ViewSomething'
    Remove-Synonym 'Xml3'
    Remove-StoredProcedure 'DoSomething'
    Remove-UserDefinedFunction 'CallTable'
    Remove-UserDefinedFunction 'CallInlineTable'
    Remove-UserDefinedFunction -SchemaName 'export' 'CallSomething'
    Remove-Schema 'export'
    Remove-Table 'Xml2'
    Remove-Table 'Xml'
    Remove-DataType 'SID'
    Invoke-Ddl 'drop xml schema collection [EmptyXsd]'
}
'@
        WhenExporting -ExcludeType @('CheckConstraint','DataType','DefaultConstraint','ForeignKey','Function','Index','PrimaryKey','Schema','StoredProcedure','Synonym','Table','Trigger','UniqueKey','View','XmlSchema') `
                    -SkipVerification
        ThenMigration -HasContent 'function Push-Migration
{
}'
        ThenMigration -HasContent 'function Pop-Migration
{
}'
    }

    It 'excludes objects by name' {
        GivenMigrationContent @'
function Push-Migration
{
    Add-DataType 'SID' -From 'int'

    Add-Table -Name 'Table1' -Column {
        int 'ID' -NotNull
        New-Column -DataType 'SID' -Name 'AnotherID' -NotNull
    }
    Add-PrimaryKey -TableName 'Table1' -ColumnName 'ID'
    Add-CheckConstraint -TableName 'Table1' -Expression '[ID]<10' -Name 'CK_Table1_ID'
    Add-DefaultConstraint -TableName 'Table1' -ColumnName 'ID' -Expression '1'
    Add-Index -TableName 'Table1' -ColumnName 'AnotherID'

    Add-Schema -Name 'export'
    Add-UserDefinedFunction -SchemaName 'export' -Name 'CallSomething' -Definition '() returns tinyint as begin return 1 end'

    Add-Schema -Name 'export2'
    Add-UserDefinedFunction -SchemaName 'export2' -Name 'CallInlineTable' -Definition '() returns table as return( select 1 as name )'

    Add-UserDefinedFunction -Name 'CallTable' -Definition '() returns @Table TABLE ( ID int primary key ) as begin insert into @Table select 1 return end'
    Add-StoredProcedure -Name 'DoSomething' -Definition 'as select 1'
    Add-Synonym -Name 'Table2' -TargetObjectName 'Table1'
    Add-Trigger -Name 'trgTable1' -Definition 'ON [dbo].[Table1] for insert as select 1'
    Add-View -Name 'ViewSomething' -Definition 'as select 1 as one'
}

function Pop-Migration
{
    Remove-View 'ViewSomething'
    Remove-Synonym 'Table2'
    Remove-StoredProcedure 'DoSomething'
    Remove-UserDefinedFunction 'CallTable'
    Remove-UserDefinedFunction -SchemaName 'export2' 'CallInlineTable'
    Remove-Schema 'export2'
    Remove-UserDefinedFunction -SchemaName 'export' 'CallSomething'
    Remove-Schema 'export'
    Remove-Table 'Table1'
    Remove-DataType 'SID'
}
'@
        WhenExporting -Exclude 'export.*' -SkipVerification
        ThenMigration -Not -HasContent '-SchemaName ''export'''
        ThenMigration -Not -HasContent 'Add-Schema -Name ''export'''
        ThenMigration -HasContent 'Add-Schema -Name ''export2'''
        ThenMigration -HasContent 'Add-Table -Name ''Table1'''
        ThenMigration -HasContent 'Add-DataType -Name ''SID'''
        ThenMigration -HasContent 'Add-Index -TableName ''Table1'''

        WhenExporting -Exclude '*.SID','*.Table1' -SkipVerification
        ThenMigration -Not -HasContent 'Add-DataType'
        ThenMigration -Not -HasContent 'Add-Table -TableName ''Table1'''
        ThenMigration -HasContent 'Add-PrimaryKey'
        ThenMigration -HasContent 'Add-CheckConstraint'
        ThenMigration -HasContent 'Add-DefaultConstraint'
        ThenMigration -HasContent 'Add-Index -TableName ''Table1'' -ColumnName ''AnotherID'''
    }

    It 'exports schema that has an extended property' {
        GivenMigrationContent @'
    function Push-Migration
    {
        Add-Schema 'snap'
        Add-ExtendedProperty -Name 'MS_Description' -Value 'This is the MS Description for the schema snap' -SchemaName 'snap'
        Add-Table -Schema 'snap' -Name 'SnapTable' -Column {
            int 'ID' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table -Schema 'snap' -Name 'SnapTable'
        Remove-Schema -Name 'snap'
    }
'@

        WhenExporting
        ThenMigration -HasContent 'Add-Schema -Name ''snap'' -Description ''This is the MS Description for the schema snap'''
        ThenMigration -HasContent 'Add-Table -SchemaName ''snap'' -Name ''SnapTable'''
    }

    It 'exports view that has an extended property' {
        GivenMigrationContent @'
    function Push-Migration
    {
        Add-Schema 'crackle'
        Add-View -SchemaName 'crackle' -Name 'CrackleView' -Definition 'as select 1 as one'
        Add-ExtendedProperty -Name 'MS_Description' -SchemaName 'crackle' -ViewName 'CrackleView' -Value 'This is the MS Description for the view CrackleView'
    }

    function Pop-Migration
    {
        Remove-View -SchemaName 'crackle' -Name 'CrackleView'
        Remove-Schema 'crackle'
    }
'@

        WhenExporting
        ThenMigration -HasContent 'Add-Schema -Name ''crackle'''
        ThenMigration -HasContent 'Add-View -SchemaName ''crackle'' -Name ''CrackleView'''
        ThenMigration -HasContent 'Add-View -SchemaName ''crackle'' -Name ''CrackleView'' -Description ''This is the MS Description for the view CrackleView'''
    }

    It 'exports view column that has an extended property' {
        GivenMigrationContent @'
    function Push-Migration
    {
        Add-Schema 'pop'
        Add-Table -Schema 'pop' -Name 'PopTable' -Column {
            int 'ID' -NotNull
        }
        Add-View -Name 'PopView' -SchemaName 'pop' -Definition 'as select * from PopTable'
        Add-ExtendedProperty -Name 'MS_Description' -SchemaName 'pop' -ViewName 'PopView' -ColumnName 'ID' -Value 'This is the MS Description for column ID in the view PopView'
    }

    function Pop-Migration
    {
        Remove-Table -SchemaName 'pop' -Name 'PopTable'
        Remove-View -SchemaName 'pop' -Name 'PopView'
        Remove-Schema 'pop'
    }
'@

        WhenExporting
        ThenMigration -HasContent 'Add-Schema -Name ''pop'''
        ThenMigration -HasContent 'Add-Table -SchemaName ''pop'' -Name ''PopTable'''
        ThenMigration -HasContent 'Add-View -SchemaName ''pop'' -Name ''PopView'''
        ThenMigration -HasContent 'Add-ExtendedProperty -SchemaName ''pop'' -ViewName ''PopView'' -ColumnName ''ID'' -Value  -Description ''This is the MS Description for column ID in the view PopView'''
    }

    It 'exports an object that references another database that was applied before it' {
        $Databases = @($RTDatabaseName, $RTDatabase2Name)

        # Has Database Order
        Start-RivetTest -PhysicalDatabase $Databases -ConfigurationDatabase $Databases
        try
        {
            $testDirectory = Get-ChildItem -Path $TestDrive
            $configFilePath = Join-Path -Path $testDirectory.FullName -ChildPath 'rivet.json'

            $db1Migration = @'
    function Push-Migration
    {
        Add-Table -Name 'Table1DB1' -Column {
            int 'ID' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table -Name 'Table1DB1'
    }
'@
            $db1Migration | New-TestMigration -Name 'ExportMigration' -DatabaseName $RTDatabaseName -ConfigFilePath $configFilePath
            Invoke-RTRivet -Push -ConfigFilePath $configFilePath -Database $RTDatabaseName

            $db2Migration = @"
    function Push-Migration
    {
        Add-View -Name 'ViewOfTable1DB1' -Definition 'as select * from $($RTDatabaseName).dbo.Table1DB1'
    }

    function Pop-Migration
    {
        Remove-View -Name 'ViewOfTable1DB1'
    }
"@
            $db2Migration | New-TestMigration -Name 'ExportMigration' -DatabaseName $RTDatabase2Name -ConfigFilePath $configFilePath
            Invoke-RTRivet -Push -ConfigFilePath $configFilePath -Database $RTDatabase2Name

            $script:migration = Export-Migration -SqlServerName $RTServer -Database $RTDatabase2Name -ConfigFilePath $configFilePath
            ThenMigration -HasContent 'Add-View -Name ''ViewOfTable1DB1'''
        }
        finally
        {
            Stop-RivetTest -DatabaseName $Databases
        }
        ThenNoErrors
    }

    It 'exports an object that references another database that was applied after it' {
        $Databases = @($RTDatabase2Name, $RTDatabaseName)

        # Has Database Order
        Start-RivetTest -PhysicalDatabase $Databases -ConfigurationDatabase $Databases

        try
        {
            $testDirectory = Get-ChildItem -Path $TestDrive
            $configFilePath = Join-Path -Path $testDirectory.FullName -ChildPath 'rivet.json'

            $db1Migration = @'
    function Push-Migration
    {
        Add-Table -Name 'Table1DB1' -Column {
            int 'ID' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table -Name 'Table1DB1'
    }
'@
            $db1Migration | New-TestMigration -Name 'ExportMigration' -DatabaseName $RTDatabaseName -ConfigFilePath $configFilePath
            Invoke-RTRivet -Push -ConfigFilePath $configFilePath -Database $RTDatabaseName

            $db2Migration = @"
    function Push-Migration
    {
        Add-View -Name 'ViewOfTable1DB1' -Definition 'as select * from $($RTDatabaseName).dbo.Table1DB1'
    }

    function Pop-Migration
    {
        Remove-View -Name 'ViewOfTable1DB1'
    }
"@
            $db2Migration | New-TestMigration -Name 'ExportMigration' -DatabaseName $RTDatabase2Name -ConfigFilePath $configFilePath
            Invoke-RTRivet -Push -ConfigFilePath $configFilePath -Database $RTDatabase2Name

            $script:migration = Export-Migration -SqlServerName $RTServer -Database $RTDatabase2Name -ConfigFilePath $configFilePath
            ThenMigration -Not -HasContent 'Add-View -Name ''ViewOfTable1DB1'''
        }
        finally
        {
            Stop-RivetTest -DatabaseName $Databases
        }
    }

    It 'exports an object that references another database and no ConfigurationDatabase is specified' {
        $Databases = @($RTDatabase2Name, $RTDatabaseName)

        # No Database Order
        Start-RivetTest -PhysicalDatabase $Databases
        try
        {
            $testDirectory = Get-ChildItem -Path $TestDrive
            $configFilePath = Join-Path -Path $testDirectory.FullName -ChildPath 'rivet.json'

            $db1Migration = @'
    function Push-Migration
    {
        Add-Table -Name 'Table1DB1' -Column {
            int 'ID' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table -Name 'Table1DB1'
    }
'@
            $db1Migration | New-TestMigration -Name 'ExportMigration' -DatabaseName $RTDatabaseName -ConfigFilePath $configFilePath
            Invoke-RTRivet -Push -ConfigFilePath $configFilePath -Database $RTDatabaseName

            $db2Migration = @"
    function Push-Migration
    {
        Add-View -Name 'ViewOfTable1DB1' -Definition 'as select * from $($RTDatabaseName).dbo.Table1DB1'
    }

    function Pop-Migration
    {
        Remove-View -Name 'ViewOfTable1DB1'
    }
"@
            $db2Migration | New-TestMigration -Name 'ExportMigration' -DatabaseName $RTDatabase2Name -ConfigFilePath $configFilePath
            Invoke-RTRivet -Push -ConfigFilePath $configFilePath -Database $RTDatabase2Name

            $script:migration = Export-Migration -SqlServerName $RTServer -Database $RTDatabase2Name -ConfigFilePath $configFilePath
            ThenMigration -HasContent 'Add-View -Name ''ViewOfTable1DB1'''
        }
        finally
        {
            Stop-RivetTest -DatabaseName $Databases
        }
        ThenNoErrors
    }
}