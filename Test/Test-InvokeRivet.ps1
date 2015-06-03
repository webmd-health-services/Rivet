& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest -IgnoredDatabase 'Ignored'
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldHandleNewMigrationForIgnoredDatabase
{
    ' ' | New-Migration -Name 'Migration' -Database 'Ignored' -ErrorAction SilentlyContinue
    Assert-Error -First 'ignored'
}

function Test-ShouldCreateDatabase
{
    $name = 'RivetConnectDatabase{0}' -f ((Get-Date).ToString('yyyyMMddHHMMss'))
    $query = 'select 1 from sys.databases where name=''{0}''' -f $name

    $conn = New-SqlConnection -Database 'master'
    $cmd = New-Object 'Data.SqlClient.SqlCommand' ($query,$conn)
    Assert-False $cmd.ExecuteScalar()

    @'
function Push-Migration
{
    Add-Schema 'fubar'
}

function Pop-Migration
{
    Remove-Schema 'fubar'
}
'@ | New-Migration -Name 'CreateDatabase' -Database $name

    try
    {
        $result = Invoke-RTRivet -Push -Database $name
        Assert-NoError
        Assert-OperationsReturned $result

        $cmd = New-Object 'Data.SqlClient.SqlCommand' ($query,$conn)
        Assert-True $cmd.ExecuteScalar()
    }
    finally
    {
        Remove-RivetTestDatabase -Name $name
        $conn.Close()
    }
}

function Test-ShouldApplyMigrationsToDuplicateDatabase
{
    $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
    $config | Add-Member -MemberType NoteProperty -Name 'TargetDatabases' -Value @{ $RTDatabaseName = @( 'InvokeRivet', 'InvokeRivet2' ) }
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

    try
    {
        $result = Invoke-RTRivet -Push -Database $RTDatabaseName
        Assert-NoError
        Assert-OperationsReturned $result

        Assert-False (Test-Schema -Name 'TargetDatabases')

        $RTDatabaseConnection.ChangeDatabase( 'InvokeRivet' )
        Assert-Schema -Name 'TargetDatabases'

        $RTDatabaseConnection.ChangeDatabase( 'InvokeRivet2' )
        Assert-Schema -Name 'TargetDatabases'
    }
    finally
    {
        Remove-RivetTestDatabase -Name 'InvokeRivet'
        Remove-RivetTestDatabase -Name 'InvokeRivet2'
    }
}

function Test-ShouldApplyMigrationsToDuplicateDatabasesWithNoMigrationsDirectory
{
    $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
    $config | Add-Member -MemberType NoteProperty -Name 'TargetDatabases' -Value @{ $RTDatabaseName = @( 'InvokeRivet', 'InvokeRivet2' ) }
    $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath

    Remove-Item -Path $RTDatabaseMigrationRoot -Recurse

    try
    {
        Remove-RivetTestDatabase -Name 'InvokeRivet'
        Remove-RivetTestDatabase -Name 'InvokeRivet2'

        $result = Invoke-RTRivet -Push -Database $RTDatabaseName
        Assert-NoError 
        Assert-OperationsReturned $result
        Assert-True (Test-Database 'InvokeRivet')
        Assert-True (Test-Database 'InvokeRivet2')
    }
    finally
    {
        Remove-RivetTestDatabase -Name 'InvokeRivet'
        Remove-RivetTestDatabase -Name 'InvokeRivet2'
    }
}

function Test-ShouldProhibitReservedRivetMigrationIDs
{
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
