

function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'InvokeRivet' 
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

    $cmd = New-Object 'Data.SqlClient.SqlCommand' ($query,$RTMasterConnection)
    Assert-False $cmd.ExecuteScalar()

    @'
function Push-Migration
{
}

function Pop-Migration
{
}
'@ | New-Migration -Name 'CreateDatabase' -Database $name

    try
    {
        $conn = Invoke-Rivet -Push -Database $name
        Assert-NoError
        Assert-Null $conn

        $cmd = New-Object 'Data.SqlClient.SqlCommand' ($query,$RTMasterConnection)
        Assert-True $cmd.ExecuteScalar()
    }
    finally
    {
        Remove-RivetTestDatabase -Name $name
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
        $result = Invoke-Rivet -Push -Database $RTDatabaseName
        Assert-NoError
        Assert-Null $result

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