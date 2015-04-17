
$pluginsPath = $null

function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'ImportPlugin' 
    $pluginsPath = New-TempDir -Prefix 'ImportPlugin'
    @'
function Add-MyTable
{
    Add-Table 'MyTable' {
        int 'ID' -Identity
    }
}
'@ | Set-Content -Path (Join-Path -Path $pluginsPath -ChildPath 'Add-MyTable.ps1')

    Start-RivetTest -PluginPath $pluginsPath
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Item -Path $pluginsPath -Recurse
}

function Test-ShouldLoadPlugins
{
    @'
function Push-Migration
{
    Add-MyTable
}
'@ | New-Migration -Name 'AddMyTable'

    Invoke-Rivet -Push

    Assert-Table 'MyTable'
}

function Test-ShouldValidatePlugins
{
    @'
function BadPlugin
{
}
'@ | Set-Content -Path (Join-Path -Path $pluginsPath -ChildPath 'Add-MyFeature.ps1')

    @'
function Push-Migration
{
    Add-Table 'MyTable' {
        int 'ID' -Identity
    }
}
'@ | New-Migration -Name 'AddMyTable'

    Invoke-Rivet -Push -ErrorAction SilentlyContinue
    Assert-Error -Last 'not found'
}

