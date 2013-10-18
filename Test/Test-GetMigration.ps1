
$getMigrationPath = Join-Path -Path $TestDir -ChildPath ..\Rivet\Get-Migration.ps1 -Resolve
$databaseName = 'GetMigration'

function Start-Test
{
    & (Join-Path -Path $TestDir -ChildPath RivetTest\Import-RivetTest.ps1 -Resolve) -DatabaseName 'GetMigration'
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldReturnMigrationObjects
{
    @'
function Push-Migration
{
    Invoke-Query 'select count(*) from sys.tables'
}

function Pop-Migration
{
    Invoke-Query 'select count(*) from sys.schemas'
}
'@ | New-Migration -Name 'Migration1'

    $migration = & $getMigrationPath -Database $RTDatabaseName -ConfigFilePath $RTConfigFilePath
    Assert-NotNull $migration
    Assert-Equal 'Rivet.Migration' $migration.GetType().FullName
    Assert-Equal $RTDatabaseName $migration.Database
    Assert-Like $migration.Path "*\$databaseName*\Migrations\*_Migration1.ps1"
    Assert-Equal 1 $migration.PushOperations.Count
    $pushOps = $migration.PushOperations
    Assert-Equal 1 $pushOps.Count
    $queryOp = $pushOps[0]
    Assert-Is $queryOp 'Rivet.Operations.RawQueryOperation' 
    Assert-Equal 'select count(*) from sys.tables' $queryOp.Query

    $popOps = $migration.PopOperations
    Assert-Equal 1 $popOps.Count
    $queryOp = $popOps[0]
    Assert-Is $queryOp 'Rivet.Operations.RawQueryOperation' 
    Assert-Equal 'select count(*) from sys.schemas' $queryOp.Query
}
