
function Push-Migration
{
    Update-StoredProcedure -SchemaName 'rivet' -Name 'InsertMigration' -Definition @'
	@ID bigint,
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

    Update-StoredProcedure -SchemaName 'rivet' -Name 'RemoveMigration' -Definition @'
	@ID bigint,
    @Name nvarchar(241),
    @Who nvarchar(50),
    @ComputerName nvarchar(50)
as
begin
	delete from [rivet].[Migrations] where [ID] = @ID
	insert into [rivet].[Activity] ([Operation],[MigrationID],[Name],[Who],[ComputerName],[AtUtc]) values ('Pop',@ID,@Name,@Who,@ComputerName,getutcdate())
end
'@

}

function Pop-Migration
{
   Update-StoredProcedure -SchemaName 'rivet' -Name 'InsertMigration' -Definition @'
	@ID bigint,
	@Name varchar(241),
	@Who varchar(50),
	@ComputerName varchar(50)
as
begin
	declare @AtUtc datetime2(7)
	select @AtUtc = getutcdate()
	insert into [rivet].[Migrations] ([ID],[Name],[Who],[ComputerName],[AtUtc]) values (@ID,@Name,@Who,@ComputerName,@AtUtc)
	insert into [rivet].[Activity] ([Operation],[MigrationID],[Name],[Who],[ComputerName],[AtUtc]) values ('Push',@ID,@Name,@Who,@ComputerName,@AtUtc)
end
'@

    Update-StoredProcedure -SchemaName 'rivet' -Name 'RemoveMigration' -Definition @'
	@ID bigint,
    @Name varchar(241),
    @Who varchar(50),
    @ComputerName varchar(50)
as
begin
	delete from [rivet].[Migrations] where [ID] = @ID
	insert into [rivet].[Activity] ([Operation],[MigrationID],[Name],[Who],[ComputerName],[AtUtc]) values ('Pop',@ID,@Name,@Who,@ComputerName,getutcdate())
end
'@

}