
function Setup
{
    & (Join-Path $TestDir RivetTest\Import-RivetTest.ps1 -Resolve) -DatabaseName 'RivetTest' 

    Start-RivetTest

    Assert-True (Test-Database)
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldCreateRivetObjectsInDatabase
{
    Invoke-Rivet -Push
    
    Assert-NoError
    Assert-True (Test-Database)
    Assert-True (Test-Schema -Name 'rivet') 'rivet schema not created'   
    Assert-True (Test-Table -Name 'Migrations' -SchemaName 'rivet') 'rivet migrations table not created'
    Assert-True (Test-Table -Name 'Activity' -SchemaName 'rivet') 'rivet activity table not created'
    Assert-True (Test-StoredProcedure -SchemaName 'rivet' -Name 'InsertMigration') 'rivet.InsertMigration stored procedure missing'
    Assert-True (Test-StoredProcedure -SchemaName 'rivet' -Name 'RemoveMigration') 'rivet.RemoveMigration stored procedure missing'
}

function Test-ShouldUpdateColumnSizeFrom50to241
{
    $rivetSchemaName = 'rivet'
    $migrationsTableName = 'Migrations'
    $activityTableName = 'Activity'
    $insertMigrationSprocName = 'InsertMigration'
    $removeMigrationSprocName = 'RemoveMigration'

    Invoke-Rivet -Push
    Assert-NoError

    $query = @'
        alter table {0}.{1} alter column Name nvarchar(50) not null
        alter table {0}.{2} alter column Name nvarchar(50) not null

        exec sp_executesql N'
            alter procedure [rivet].[InsertMigration]
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

        exec sp_executesql N'
	        alter procedure [rivet].[RemoveMigration]
	            @ID bigint,
                @Name varchar(241),
                @Who varchar(50),
                @ComputerName varchar(50)
            as
            begin
	            delete from [rivet].[Migrations] where [ID] = @ID
	            insert into [rivet].[Activity] ([Operation],[MigrationID],[Name],[Who],[ComputerName],[AtUtc]) values (''Pop'',@ID,@Name,@Who,@ComputerName,getutcdate())
            end
        '

        delete from [rivet].[Migrations] where ID=00000000000002

'@ -f $rivetSchemaName, $migrationsTableName, $activityTableName
    Invoke-RivetTestQuery -Query $query
    
    Invoke-Rivet -Push
    Assert-NoError

    Assert-Column -TableName 'Migrations' -SchemaName 'rivet' -Name 'Name' -DataType 'nvarchar' -Size 241 -NotNull
    Assert-Column -TableName 'Activity' -SchemaName 'rivet' -Name 'Name' -DataType 'nvarchar' -Size 241 -NotNull

    $query = @'
        select p.max_length
        from sys.procedures sp
        join sys.parameters p on sp.object_id = p.object_id
        join sys.schemas s on s.name = '{0}'
        where sp.name = '{1}' and p.name = '@Name'
'@ -f $rivetSchemaName, $insertMigrationSprocName

    Assert-Equal -Expected 241 -Actual (Invoke-RivetTestQuery -Query $query).max_length

    $query = @'
        select p.max_length
        from sys.procedures sp
        join sys.parameters p on sp.object_id = p.object_id
        join sys.schemas s on s.name = '{0}'
        where sp.name = '{1}' and p.name = '@Name'
'@ -f $rivetSchemaName, $removeMigrationSprocName

    Assert-Equal -Expected 241 -Actual (Invoke-RivetTestQuery -Query $query).max_length
}

function Test-ShouldRenamePstepSchemaToRivet
{
    $oldSchemaName = 'pstep'
    $rivetSchemaName = 'rivet'
    Invoke-Rivet -Push
    Assert-NoError
    $expectedCount = Measure-Migration
        
    Invoke-RivetTestQuery -Query ('create schema {0}' -f $oldSchemaName)

    Invoke-RivetTestQuery -Query ('alter schema {0} transfer {1}.Migrations' -f $oldSchemaName,$RivetSchemaName)

    Invoke-RivetTestQuery -Query ('drop table [{0}].[Activity]' -f $RivetSchemaName)
    Invoke-RivetTestQuery -Query ('drop procedure [{0}].[InsertMigration]' -f $RivetSchemaName)
    Invoke-RivetTestQuery -Query ('drop procedure [{0}].[RemoveMigration]' -f $RivetSchemaName)

    Invoke-RivetTestQuery -Query ('drop schema {0}' -f $RivetSchemaName)

    Invoke-RivetTestQuery -Query 'delete from [pstep].[Migrations] where ID=00000000000001'

    Assert-False (Test-Table -Name 'Migrations' -SchemaName $RivetSchemaName)
    Assert-True (Test-Table -Name 'Migrations' -SchemaName $oldSchemaName) 
    Assert-False (Test-Schema -Name $RivetSchemaName)
    Assert-True (Test-Schema -Name $oldSchemaName)

    Invoke-Rivet -Push
    Assert-NoError
    $actualCount = Measure-Migration
    Assert-Equal $expectedCount $actualCount

    Assert-True (Test-Table -Name 'Migrations' -SchemaName $RivetSchemaName)
    Assert-False (Test-Table -Name 'Migrations' -SchemaName $oldSchemaName)
    Assert-True (Test-Schema -Name $RivetSchemaName)
    Assert-False (Test-Schema -Name $oldSchemaName)
}

function Test-ShouldChangeAtUtcToDatetime2
{
    Invoke-Rivet -Push
    Assert-NoError

    $rivetSchemaName = 'rivet'
    $migrationsTableName = 'Migrations'

    $assertColumnParams = @{ 
                                TableName = $migrationsTableName ; 
                                SchemaName = $rivetSchemaName ; 
                                Name = 'AtUtc' ;
                                NotNull = $true ;
                           }
    Assert-Column -DataType 'datetime2' @assertColumnParams

    $query = @'
        alter table {0}.{1} drop constraint DF_rivet_Migrations_AtUtc
        alter table {0}.{1} alter column Atutc datetime not null
        alter table {0}.{1} add constraint AtUtcDefault default (GetUtcDate()) for AtUtc
        delete from [rivet].[Migrations] where ID=00000000000001
'@ -f $rivetSchemaName,$migrationsTableName
    Invoke-RivetTestQuery -Query $query
    Assert-Column -DataType 'datetime' @assertColumnParams

    Invoke-Rivet -Push
    Assert-NoError
    Assert-Column -DataType 'datetime2' @assertColumnParams
}