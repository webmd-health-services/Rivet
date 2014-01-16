
function Initialize-Database
{
    <#
    .SYNOPSIS
    Intializes the database so that it can be migrated by Rivet.
    #>
    param(
    )

    $Connection.Transaction = $Connection.BeginTransaction()

    try
    {
        $query = @'
if not exists (select * from sys.schemas where name = 'rivet')
    exec sp_executesql N'create schema [rivet]'

if object_id('pstep.Migrations', 'U') is not null
    alter schema [rivet] transfer [pstep].[Migrations]

if exists (select * from sys.schemas where name = 'pstep')
    drop schema [pstep]

if object_id('rivet.Migrations', 'U') is null
begin
    create table [rivet].[Migrations] (
        [ID] bigint not null,
        [Name] nvarchar(50) not null,
        [Who] nvarchar(50) not null,
        [ComputerName] nvarchar(50) not null,
        [AtUtc] datetime not null
    )

    alter table [rivet].[Migrations] add constraint [MigrationsPK] primary key ( [ID] ) 

    alter table [rivet].[Migrations] add constraint [AtUtcDefault]  default (getutcdate()) for [AtUtc]
end

if object_id('rivet.AtUtcDefault', 'D') is not null and object_id('rivet.DF_Migrations_AtUtc', 'D') is null
begin
    exec sp_rename 'rivet.AtUtcDefault', 'DF_rivet_Migrations_AtUtc', 'OBJECT'
end

if exists (select * from sys.columns c join 
						sys.tables t on c.object_id = t.object_id join 
						sys.types y on c.system_type_id = y.system_type_id 
					where 
						schema_name(t.schema_id) = 'rivet' and 
						t.name = 'Migrations' and 
						c.name = 'AtUtc' and 
						y.name = 'datetime') 
begin
    alter table [rivet].[Migrations] drop constraint [DF_rivet_Migrations_AtUtc]
    alter table [rivet].[Migrations] alter column [AtUtc] datetime2(7) not null
    alter table [rivet].[Migrations] add constraint [DF_rivet_Migrations_AtUtc] default (GetUtcDate()) for [AtUtc]
end

if object_id('rivet.MigrationsPK', 'PK') is not null and object_id('rivet.PK_rivet_Migrations', 'PK') is null
begin
    exec sp_rename 'rivet.MigrationsPK', 'PK_rivet_Migrations', 'OBJECT'
end

if object_id('rivet.Activity', 'U') is null
begin
    create table [rivet].[Activity] (
        [ID] int identity,
        [Operation] nvarchar(4) not null,
        [MigrationID] bigint not null,
        [Name] nvarchar(50) not null,
        [Who] nvarchar(50) not null,
        [ComputerName] nvarchar(50) not null,
        [AtUtc] datetime2(7) not null
    )

    alter table [rivet].[Activity] add constraint [PK_rivet_Activity_ID] primary key ([ID])

    alter table [rivet].[Activity] add constraint [DF_rivet_Activity_AtUtc]  DEFAULT (getutcdate()) FOR [AtUtc]

    alter table [rivet].[Activity] with check add constraint [CK_rivet_Activity_Operation] CHECK  (([Operation]='Push' OR [Operation]='Pop'))
end

if object_id('rivet.PK_rivet_Activity_ID', 'PK') is not null and object_id('rivet.PK_rivet_Activity', 'PK') is null
begin
    exec sp_rename 'rivet.PK_rivet_Activity_ID', 'PK_rivet_Activity', 'OBJECT'
end
'@

        $null = Invoke-Query -Query $query -NonQuery -Verbose:$false
            
        $Connection.Transaction.Commit()
    }
    catch
    {
        $Connection.Transaction.Rollback()
            
         Write-RivetError -Message 'Failed to initialize database so it can be migrated by Rivet.' -CategoryInfo $_.CategoryInfo.Category -ErrorID $_.FullyQualifiedErrorID -Exception $_.Exception -CallStack ($_.ScriptStackTrace)
    }
}
