
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
    Remove-RivetTestDatabase
    @'
function Push-Migration
{
    Add-Schema 'initialize'
}

function Pop-Migration
{
    Remove-Schema 'initialize'
}
'@ | New-Migration -Name 'First'
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateRivetObjectsInDatabase
{
    Invoke-Rivet -Push | Format-Table | Out-String | Write-Verbose
    
    Assert-NoError

    # Migration #1
    Assert-True (Test-Database)
    Assert-True (Test-Schema -Name 'rivet') 'rivet schema not created'   
    Assert-True (Test-Table -Name 'Migrations' -SchemaName 'rivet') 'rivet migrations table not created'
    Assert-True (Test-Table -Name 'Activity' -SchemaName 'rivet') 'rivet activity table not created'
    Assert-True (Test-StoredProcedure -SchemaName 'rivet' -Name 'InsertMigration') 'rivet.InsertMigration stored procedure missing'
    Assert-True (Test-StoredProcedure -SchemaName 'rivet' -Name 'RemoveMigration') 'rivet.RemoveMigration stored procedure missing'

    # Migration #2 and #3
    Assert-Column -TableName 'Migrations' -SchemaName 'rivet' -Name 'Name' -DataType 'nvarchar' -Size 241 -NotNull
    Assert-Column -TableName 'Activity' -SchemaName 'rivet' -Name 'Name' -DataType 'nvarchar' -Size 241 -NotNull
    $query = @'
        select sp.name, p.name as parameter_name, p.max_length, t.name as type_name
        from sys.procedures sp
        join sys.parameters p on sp.object_id = p.object_id
        join sys.schemas s on sp.schema_id = s.schema_id
        join sys.types t on p.user_type_id = t.user_type_id
        where s.name = '{0}' and sp.name in ('InsertMigration','RemoveMigration') and p.name in ('@Name','@Who','@ComputerName')
'@ -f $RTRivetSchemaName

    Write-Verbose $query

    $rows = Invoke-RivetTestQuery -Query $query
    foreach( $row in $rows )
    {
        Assert-Equal 'nvarchar' $row.type_name ('{0} {1}: not correct column type' -f $row.name,$row.parameter_name)
        if( $row.parameter_name -eq '@Name' )
        {
            # Parameters are nvarchar, so each character is two bytes.
            Assert-Equal -Expected (241 * 2) -Actual $row.max_length
        }

    }
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