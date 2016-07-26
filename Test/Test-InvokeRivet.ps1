
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest -IgnoredDatabase 'Ignored'
}

function Stop-Test
{
    Stop-RivetTest
    Clear-TestDatabase -Name $RTDatabase2Name
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
'@ | New-TestMigration -Name 'CreateDatabase'

    $result = Invoke-RTRivet -Push
    Assert-NoError
    Assert-OperationsReturned $result

    Assert-True (Invoke-RivetTestQuery -Query $query -Master -AsScalar)
}

function Test-ShouldApplyMigrationsToDuplicateDatabase
{
    $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
    $config | Add-Member -MemberType NoteProperty -Name 'TargetDatabases' -Value @{ $RTDatabaseName = @( $RTDatabaseName, $RTDatabase2Name ) }
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
'@ | New-TestMigration -Name 'TargetDatabases' -Database $RTDatabaseName

    $result = Invoke-RTRivet -Push -Database $RTDatabaseName
    Assert-NoError
    Assert-OperationsReturned $result

    Assert-Schema -Name 'TargetDatabases'
    Assert-Schema -Name 'TargetDatabases' -DatabaseName $RTDatabase2Name
}

function Test-ShouldCreateTargetDatabases
{
    Remove-RivetTestDatabase
    Remove-RivetTestDatabase -Name $RTDatabase2Name

    $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
    $config | Add-Member -MemberType NoteProperty -Name 'TargetDatabases' -Value @{ $RTDatabaseName = @( $RTDatabaseName, $RTDatabase2Name ) }
    $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath

    Remove-Item -Path $RTDatabaseMigrationRoot -Recurse

    $result = Invoke-RTRivet -Push -Database $RTDatabaseName
    Assert-NoError 
    Assert-True (Test-Database)
    Assert-True (Test-Database $RTDatabase2Name)
}

function Test-ShouldWriteErrorIfMigratingIgnoredDatabase
{
    Push-Location -Path (Split-Path -Parent -Path $RTConfigFilePath)
    try
    {
        & $RTRivetPath -Push -Database 'Ignored' -ErrorAction SilentlyContinue
        Assert-Error -Last -Regex ([regex]::Escape($RTConfigFilePath))
    }
    finally
    {
        Pop-Location
    }
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
'@ | New-TestMigration -Name 'HasReservedID' -Database $RTDatabaseName    

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

function Test-ShouldCreateMultipleMigrations
{
    $m = Invoke-Rivet -New -Name 'One','Two' -ConfigFilePath $RTConfigFilePath
    try
    {
        Assert-NoError
        Assert-Is $m ([object[]])
        Assert-Like $m[0].Name '*_One.ps1'
        Assert-Like $m[1].Name '*_Two.ps1'
    }
    finally
    {
        $m | Remove-Item
    }
}

function Test-ShouldPushMultipleMigrations
{
    $m = @( 'One', 'Two', 'Three' ) |
            ForEach-Object {
                                @'
function Push-Migration { Invoke-Ddl 'select 1' }
function Pop-Migration { Invoke-Ddl 'select 1' }
'@ | New-TestMigration -Name $_
            }
    [Rivet.OperationResult[]]$result = Invoke-Rivet -Push -Name 'One','Three' -ConfigFilePath $RTConfigFilePath
    Assert-OperationsReturned $result
    Assert-Equal 'One' $result[0].Migration.Name
    Assert-Equal 'Three' $result[1].Migration.Name
}

function Test-ShouldPopMultipleMigrations
{
    $m = @( 'One', 'Two', 'Three' ) |
            ForEach-Object {
                                @'
function Push-Migration { Invoke-Ddl 'select 1' }
function Pop-Migration { Invoke-Ddl 'select 1' }
'@ | New-TestMigration -Name $_
            }
    Invoke-Rivet -Push -Name 'One','Three' -ConfigFilePath $RTConfigFilePath
    [Rivet.OperationResult[]]$result = Invoke-Rivet -Pop -Name 'One','Three' -ConfigFilePath $RTConfigFilePath
    Assert-OperationsReturned $result
    Assert-Equal 'Three' $result[0].Migration.Name
    Assert-Equal 'One' $result[1].Migration.Name
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
