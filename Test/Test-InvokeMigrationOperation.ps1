function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddAdminColumnPlugin'
    $tempPluginsPath = New-TempDir -Prefix 'AddAdminColumnPlugin'
    $pluginPath = Join-Path -Path $TestDir -ChildPath '..\Rivet\Extras\*-MigrationOperation.ps1' -Resolve
    Copy-Item -Path $pluginPath -Destination $tempPluginsPath
    Start-RivetTest -PluginPath $tempPluginsPath
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldRunPlugins
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        BigInt ID
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CompleteAdminPlugin'

    Invoke-Rivet -Push 'CompleteAdminPlugin'

    Assert-Column -Name CreateDate -DataType smalldatetime -NotNull -TableName "Foobar"
    Assert-Column -Name LastUpdated -DataType datetime -NotNull -TableName "Foobar"
    Assert-Column -Name RowGuid -DataType uniqueidentifier -NotNull -RowGuidCol -TableName "Foobar"
    Assert-Column -Name SkipBit -DataType bit -TableName "Foobar"
    Assert-Index -TableName 'Foobar' -ColumnName 'rowguid' -Unique
    Assert-Trigger -Name 'trFoobar_Activity'
}

function Test-PluginsShouldSkipRowGuid
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        uniqueidentifier guid -RowGuidCol
    }
}

function Pop-Migration
{
    Remove-Table Foobar
}
'@ | New-Migration -Name 'SkipRowGuid'

    Invoke-Rivet -Push 'SkipRowGuid'

    Assert-Column -Name guid -DataType uniqueidentifier -RowGuidCol -TableName "Foobar"
    Assert-False (Test-Column -TableName 'Foobar' -Name 'rowguid')
}