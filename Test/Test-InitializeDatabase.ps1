
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
    
    Assert-True (Test-Database)
    Assert-True (Test-Schema -Name 'rivet') 'rivet schema not created'   
    Assert-True (Test-Table -Name 'Migrations' -SchemaName 'rivet') 'rivet migrations table not created'
    Assert-True (Test-Table -Name 'Activity' -SchemaName 'rivet') 'rivet activity table not created'
}

function Test-ShouldRenamePstepSchemaToRivet
{
    $oldSchemaName = 'pstep'
    $rivetSchemaName = 'rivet'
    Invoke-Rivet -Push
    $expectedCount = Measure-Migration
        
    Invoke-RivetTestQuery -Query ('create schema {0}' -f $oldSchemaName)

    Invoke-RivetTestQuery -Query ('alter schema {0} transfer {1}.Migrations' -f $oldSchemaName,$RivetSchemaName)

    Invoke-RivetTestQuery -Query ('alter schema {0} transfer {1}.Activity' -f $oldSchemaName,$RivetSchemaName)

    Invoke-RivetTestQuery -Query ('drop schema {0}' -f $RivetSchemaName)

    Assert-False (Test-Table -Name 'Migrations' -SchemaName $RivetSchemaName)
    Assert-True (Test-Table -Name 'Migrations' -SchemaName $oldSchemaName) 
    Assert-False (Test-Schema -Name $RivetSchemaName)
    Assert-True (Test-Schema -Name $oldSchemaName)

    Invoke-Rivet -Push
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

    $rivetSchemaName = 'rivet'
    $migrationsTableName = 'Migrations'

    $assertColumnParams = @{ 
                                TableName = $migrationsTableName ; 
                                SchemaName = $rivetSchemaName ; 
                                Name = 'Atutc' ;
                                NotNull = $true ;
                           }
    Assert-Column -DataType 'datetime2' @assertColumnParams

    $query = @'
        alter table {0}.{1} drop constraint AtUtcDefault
        alter table {0}.{1} alter column Atutc datetime not null
        alter table {0}.{1} add constraint AtUtcDefault default (GetUtcDate()) for Atutc
'@ -f $rivetSchemaName,$migrationsTableName
    Invoke-RivetTestQuery -Query $query
    Assert-Column -DataType 'datetime' @assertColumnParams

    Invoke-Rivet -Push
    Assert-Column -DataType 'datetime2' @assertColumnParams
}