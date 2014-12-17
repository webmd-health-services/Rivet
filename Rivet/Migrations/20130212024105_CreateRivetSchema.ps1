
function Push-Migration
{
    Invoke-Query -Query @'
if not exists (select * from sys.schemas where name = 'rivet')
    exec sp_executesql N'create schema [rivet] authorization [dbo]'

if not exists (select * from 
                            sys.schemas s join 
                            sys.database_principals dp on s.principal_id = dp.principal_id 
                        where 
                            s.name = 'rivet' and 
                            dp.name = 'dbo')
    alter authorization on schema::[rivet] to [dbo]

if not exists (select * from 
                            sys.database_permissions dbperms join 
                            sys.schemas s on dbperms.major_id=s.schema_id join 
                            sys.database_principals dbid on dbperms.grantee_principal_id = dbid.principal_id 
                        where 
                            s.name = 'rivet' and 
                            dbid.name = 'public')
    grant control on schema::[rivet] to [public]

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

if object_id('rivet.InsertMigration', 'P') is null 
    exec sp_executesql N'
        create procedure [rivet].[InsertMigration]
	        @ID bigint,
	        @Name varchar(50),
	        @Who varchar(50),
	        @ComputerName varchar(50)
        as
        begin
	        declare @AtUtc datetime2(7)
	        select @AtUtc = getutcdate()
	        insert into [rivet].[Migrations] ([ID],[Name],[Who],[ComputerName],[AtUtc]) values (@ID,@Name,@Who,@ComputerName,@AtUtc)
	        insert into [rivet].[Activity] ([Operation],[MigrationID],[Name],[Who],[ComputerName],[AtUtc]) values (''Push'',@ID,@Name,@Who,@ComputerName,@AtUtc)
        end
    '

if object_id('rivet.RemoveMigration', 'P') is null 
    exec sp_executesql N'
        create procedure [rivet].[RemoveMigration]
	        @ID bigint,
            @Name varchar(50),
            @Who varchar(50),
            @ComputerName varchar(50)
        as
        begin
	        delete from [rivet].[Migrations] where [ID] = @ID
	        insert into [rivet].[Activity] ([Operation],[MigrationID],[Name],[Who],[ComputerName],[AtUtc]) values (''Pop'',@ID,@Name,@Who,@ComputerName,getutcdate())
        end
    '
'@
}

function Pop-Migration
{
    Remove-StoredProcedure -SchemaName 'rivet' -Name 'RemoveMigration'
    Remove-StoredProcedure -SchemaName 'rivet' -Name 'InsertMigration'
    Remove-Table -SchemaName 'rivet' -Name 'Activity'
    Remove-Table -SchemaName 'rivet' -Name 'Migrations'
    Remove-Schema -Name 'rivet'
}