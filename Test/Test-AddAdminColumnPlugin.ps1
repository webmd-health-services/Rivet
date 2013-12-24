function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddAdminColumnPlugin'
    $tempPluginsPath = New-TempDir -Prefix 'AddAdminColumnPlugin'
    New-Item -Path (Join-Path -Path $tempPluginsPath -ChildPath '\Plugins\') -ItemType directory
    $pluginPath = Join-Path -Path $TestDir -ChildPath '..\Rivet\Extras\Complete-AddTable.ps1' -Resolve
    Copy-Item -Path $pluginPath -Destination $tempPluginsPath\Plugins\
    Start-RivetTest -PluginPath $tempPluginsPath
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-CompleteAdminPlugin
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
}