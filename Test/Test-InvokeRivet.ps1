

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

    $conn = Invoke-Rivet -Push -Database $name
    Assert-NoError
    Assert-Null $conn

    $cmd = New-Object 'Data.SqlClient.SqlCommand' ($query,$RTMasterConnection)
    Assert-True $cmd.ExecuteScalar()
}
