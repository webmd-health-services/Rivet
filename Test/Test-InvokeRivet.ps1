
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
$db2Name = 'TestInvokeRivet'

function Start-Test
{
    Start-RivetTest -IgnoredDatabase 'Ignored'
}

function Stop-Test
{
    Stop-RivetTest
    Clear-TestDatabase -Name $db2Name
}

function Test-ShouldHandleNewMigrationForIgnoredDatabase
{
    ' ' | New-Migration -Name 'Migration' -Database 'Ignored' -ErrorAction SilentlyContinue
    Assert-Error -First 'ignored'
}

function Test-ShouldCreateDatabase
{
    Remove-RivetTestDatabase

    $query = 'select 1 from sys.databases where name=''{0}''' -f $RTDatabaseName

    Assert-False (Invoke-RivetTestQuery -Query $query -Master -AsScalar)

    @'
function Push-Migration
{
    Add-Schema 'fubar'
}

function Pop-Migration
{
    Remove-Schema 'fubar'
}
'@ | New-Migration -Name 'CreateDatabase'

    $result = Invoke-RTRivet -Push
    Assert-NoError
    Assert-OperationsReturned $result

    Assert-True (Invoke-RivetTestQuery -Query $query -Master -AsScalar)
}

function Test-ShouldApplyMigrationsToDuplicateDatabase
{
    $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
    $config | Add-Member -MemberType NoteProperty -Name 'TargetDatabases' -Value @{ $RTDatabaseName = @( $RTDatabaseName, $db2Name ) }
    $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath

    @'
function Push-Migration
{
    Add-Schema 'TargetDatabases'
}

function Pop-Migration
{
    Remove-Schema 'TargetDatabases'
}
'@ | New-Migration -Name 'TargetDatabases' -Database $RTDatabaseName

    $result = Invoke-RTRivet -Push -Database $RTDatabaseName
    Assert-NoError
    Assert-OperationsReturned $result

    Assert-Schema -Name 'TargetDatabases'
    Assert-Schema -Name 'TargetDatabases' -DatabaseName $db2Name
}

function Test-ShouldCreateTargetDatabases
{
    Remove-RivetTestDatabase
    Remove-RivetTestDatabase -Name $db2Name

    $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
    $config | Add-Member -MemberType NoteProperty -Name 'TargetDatabases' -Value @{ $RTDatabaseName = @( $RTDatabaseName, $db2Name ) }
    $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath

    Remove-Item -Path $RTDatabaseMigrationRoot -Recurse

    $result = Invoke-RTRivet -Push -Database $RTDatabaseName
    Assert-NoError 
    Assert-True (Test-Database)
    Assert-True (Test-Database $db2Name)
}

function Test-ShouldProhibitReservedRivetMigrationIDs
{
    $startedAt = Get-Date
    $file = @'
function Push-Migration
{
    Add-Schema 'fubar'
}

function Pop-Migration
{
    Remove-Schema 'fubar'
}
'@ | New-Migration -Name 'HasReservedID' -Database $RTDatabaseName    

    Assert-NotNull $file
    $file = Rename-Item -Path $file -NewName ('00999999999999_HasReservedID.ps1') -PassThru

    Invoke-RTRivet -Push -ErrorAction SilentlyContinue
    Assert-Error -Last -Regex 'reserved'
    Assert-False (Test-Schema -Name 'fubar')

    $Global:Error.Clear()
    Rename-Item -Path $file -NewName ('01000000000000_HasReservedID.ps1')
    Invoke-RTRivet -Push 
    Assert-NoError
    Assert-Schema -Name 'fubar'
}

function Test-ShouldHandleFailureToConnect
{
    $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
    $originalSqlServerName = $config.SqlServerName
    $config.SqlServerName = '.\IDoNotExist'
    $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath

    try
    {
        Invoke-RTRivet -Push -ErrorAction SilentlyContinue
        Assert-Error -Last -Regex 'failed to connect'
    }
    finally
    {
        $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
        $config.SqlServerName = $originalSqlServerName
        $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath
    }
}

function Assert-OperationsReturned
{
    param(
        [object[]]
        $Operation
    )

    Assert-NotNull $Operation
    $Operation | ForEach-Object { Assert-Is $_ ([Rivet.OperationResult]) }
}
