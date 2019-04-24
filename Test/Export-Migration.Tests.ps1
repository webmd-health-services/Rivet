
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
        [Parameter(Mandatory)]
        [string[]]
        $Name
    )

    Start-RivetTest
    try
    {
        Invoke-RTRivet -Push
        $script:migration = Export-Migration -SqlServerName $RTServer -DAtabase $RTDatabaseName -Name $Name
        Write-Debug -Message ($migration -join [Environment]::NewLine)
    }
    finally
    {
        Stop-RivetTest
    }
}

Describe 'Export-Migration.when exporting Rivet''s Migrations table' {
    Init
    WhenExporting 'rivet.Migrations'
    ThenMigration -HasContent @'
    Add-Table -SchemaName 'rivet' -Name 'Migrations' -Column {
        bigint 'ID' -NotNull
        nvarchar 'Name' -Size 241 -NotNull
        nvarchar 'Who' -Size 50 -NotNull
        nvarchar 'ComputerName' -Size 50 -NotNull
        datetime2 'AtUtc' -NotNull
    }
    Add-PrimaryKey -SchemaName 'rivet' -TableName 'Migrations' -ColumnName 'ID' -Name 'PK_rivet_Migrations'
    Add-DefaultConstraint -SchemaName 'rivet' -TableName 'Migrations' -Name 'DF_rivet_Migrations_AtUtc' -Expression '(getutcdate())'
'@
    ThenMigration -HasContent 'Remove-Table -SchemaName ''rivet'' -Name ''Migrations'''
    ThenMigration -Not -HasContent 'Remove-PrimaryKey'
    ThenMigration -Not -HasContent 'Remove-DefaultConstraint'
}

Describe 'Export-Migration.when exporting Rivet''s Activity table' {
    Init
    WhenExporting 'rivet.Activity'
    ThenMigration -HasContent @'
    Add-Table -SchemaName 'rivet' -Name 'Activity' -Column {
        int 'ID' -NotNull
        nvarchar 'Operation' -Size 4 -NotNull
        bigint 'MigrationID' -NotNull
        nvarchar 'Name' -Size 241 -NotNull
        nvarchar 'Who' -Size 50 -NotNull
        nvarchar 'ComputerName' -Size 50 -NotNull
        datetime2 'AtUtc' -NotNull
    }
    Add-PrimaryKey -SchemaName 'rivet' -TableName 'Activity' -ColumnName 'ID' -Name 'PK_rivet_Activity'
    Add-DefaultConstraint -SchemaName 'rivet' -TableName 'Activity' -Name 'DF_rivet_Activity_AtUtc' -Expression '(getutcdate())'
    Add-CheckConstraint -SchemaName 'rivet' -TableName 'Activity' -Name 'CK_rivet_Activity_Operation' -Expression '([Operation]='Push' OR [Operation]='Pop')'
'@
    ThenMigration -HasContent 'Remove-Table -SchemaName ''rivet'' -Name ''Activity'''
    ThenMigration -Not -HasContent 'Remove-PrimaryKey'
    ThenMigration -Not -HasContent 'Remove-DefaultConstraint'
    ThenMigration -Not -HasContent 'Remove-CheckConstraint'
}

Describe 'Export-Migration.when exporting all Rivet''s objects' {
    Init
    WhenExporting 'rivet.*'
    ThenMigration -HasContent @'
    Add-Table -SchemaName 'rivet' -Name 'Migrations' -Column {
        bigint 'ID' -NotNull
        nvarchar 'Name' -Size 241 -NotNull
        nvarchar 'Who' -Size 50 -NotNull
        nvarchar 'ComputerName' -Size 50 -NotNull
        datetime2 'AtUtc' -NotNull
    }
    Add-PrimaryKey -SchemaName 'rivet' -TableName 'Migrations' -ColumnName 'ID' -Name 'PK_rivet_Migrations'
'@
    ThenMigration -HasContent @'
    Add-Table -SchemaName 'rivet' -Name 'Activity' -Column {
        int 'ID' -NotNull
        nvarchar 'Operation' -Size 4 -NotNull
        bigint 'MigrationID' -NotNull
        nvarchar 'Name' -Size 241 -NotNull
        nvarchar 'Who' -Size 50 -NotNull
        nvarchar 'ComputerName' -Size 50 -NotNull
        datetime2 'AtUtc' -NotNull
    }
    Add-PrimaryKey -SchemaName 'rivet' -TableName 'Activity' -ColumnName 'ID' -Name 'PK_rivet_Activity'
    Add-DefaultConstraint -SchemaName 'rivet' -TableName 'Activity' -Name 'DF_rivet_Activity_AtUtc' -Expression '(getutcdate())'
    Add-CheckConstraint -SchemaName 'rivet' -TableName 'Activity' -Name 'CK_rivet_Activity_Operation' -Expression '([Operation]='Push' OR [Operation]='Pop')'
'@
    ThenMigration -HasContent @"
    Invoke-Ddl -Query @'CREATE procedure [rivet].[InsertMigration] 	@ID bigint,
	@Name nvarchar(241),
	@Who nvarchar(50),
	@ComputerName nvarchar(50)
as
begin
	declare @AtUtc datetime2(7)
	select @AtUtc = getutcdate()
	insert into [rivet].[Migrations] ([ID],[Name],[Who],[ComputerName],[AtUtc]) values (@ID,@Name,@Who,@ComputerName,@AtUtc)
	insert into [rivet].[Activity] ([Operation],[MigrationID],[Name],[Who],[ComputerName],[AtUtc]) values ('Push',@ID,@Name,@Who,@ComputerName,@AtUtc)
end
'@
"@
    ThenMigration -HasContent @"
    Invoke-Ddl -Query @'CREATE procedure [rivet].[RemoveMigration] 	@ID bigint,
    @Name nvarchar(241),
    @Who nvarchar(50),
    @ComputerName nvarchar(50)
as
begin
	delete from [rivet].[Migrations] where [ID] = @ID
	insert into [rivet].[Activity] ([Operation],[MigrationID],[Name],[Who],[ComputerName],[AtUtc]) values ('Pop',@ID,@Name,@Who,@ComputerName,getutcdate())
end
'@
"@
    ThenMigration -HasContent 'Remove-Table -SchemaName ''rivet'' -Name ''Migrations'''
    ThenMigration -HasContent 'Remove-Table -SchemaName ''rivet'' -Name ''Activity'''
    ThenMigration -HasContent 'Remove-StoredProcedure -SchemaName ''rivet'' -Name ''InsertMigration'''
    ThenMigration -HasContent 'Remove-StoredProcedure -SchemaName ''rivet'' -Name ''RemoveMigration'''
}

Describe 'Export-Migration.when exporting a default constraint' {
    Init
    WhenExporting 'rivet.DF_rivet_Migrations_AtUtc'
    ThenMigration -HasContent 'Add-DefaultConstraint -SchemaName ''rivet'' -TableName ''Migrations'' -Name ''DF_rivet_Migrations_AtUtc'' -Expression ''(getutcdate())'''
    ThenMigration -HasContent 'Remove-DefaultConstraint -SchemaName ''rivet'' -TableName ''Migrations'' -Name ''DF_rivet_Migrations_AtUtc'''
}

Describe 'Export-Migration.when exporting a primary key' {
    Init
    WhenExporting 'rivet.PK_rivet_Migrations'
    ThenMigration -HasContent 'Add-PrimaryKey -SchemaName ''rivet'' -TableName ''Migrations'' -ColumnName ''ID'' -Name ''PK_rivet_Migrations'''
    ThenMigration -HasContent 'Remove-PrimaryKey -SchemaName ''rivet'' -TableName ''Migrations'' -Name ''PK_rivet_Migrations'''
}

Describe 'Export-Migration.when exporting a check constraint' {
    Init
    WhenExporting 'rivet.CK_rivet_Activity_Operation'
    ThenMigration -HasContent 'Add-CheckConstraint -SchemaName ''rivet'' -TableName ''Activity'' -Name ''CK_rivet_Activity_Operation'' -Expression ''([Operation]=''Push'' OR [Operation]=''Pop'')'''
    ThenMigration -HasContent 'Remove-CheckConstraint -SchemaName ''rivet'' -TableName ''Activity'' -Name ''CK_rivet_Activity_Operation'''
}

Describe 'Export-Migration.when exporting a stored procedure' {
    Init
    WhenExporting 'rivet.RemoveMigration'
    ThenMigration -HasContent @"
    Invoke-Ddl -Query @'CREATE procedure [rivet].[RemoveMigration] 	@ID bigint,
    @Name nvarchar(241),
    @Who nvarchar(50),
    @ComputerName nvarchar(50)
as
begin
	delete from [rivet].[Migrations] where [ID] = @ID
	insert into [rivet].[Activity] ([Operation],[MigrationID],[Name],[Who],[ComputerName],[AtUtc]) values ('Pop',@ID,@Name,@Who,@ComputerName,getutcdate())
end
'@
"@
    ThenMigration -HasContent 'Remove-StoredProcedure -SchemaName ''rivet'' -Name ''RemoveMigration'''

}
