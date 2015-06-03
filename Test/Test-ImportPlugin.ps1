
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
$pluginsPath = $null

function Start-Test
{
    $pluginsPath = New-TempDir -Prefix 'ImportPlugin'
    @'
function Add-MyTable
{
    Add-Table 'MyTable' {
        int 'ID' -Identity
    }
}
'@ | Set-Content -Path (Join-Path -Path $pluginsPath -ChildPath 'Add-MyTable.ps1')

    @'
function Remove-MyTable
{
    Remove-Table 'MyTable' 
}
'@ | Set-Content -Path (Join-Path -Path $pluginsPath -ChildPath 'Remove-MyTable.ps1')

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

function Pop-Migration
{
    Remove-MyTable
}
'@ | New-Migration -Name 'AddMyTable'

    Invoke-RTRivet -Push

    Assert-Table 'MyTable'
}

function Test-ShouldValidatePlugins
{
    $badPluginPath = Join-Path -Path $pluginsPath -ChildPath 'Add-MyFeature.ps1'
    @'
function BadPlugin
{
}
'@ | Set-Content -Path $badPluginPath

    @'
function Push-Migration
{
    Add-Table 'MyTable' {
        int 'ID' -Identity
    }
}

function Pop-Migration
{
    Remove-Table 'MyTable'
}
'@ | New-Migration -Name 'AddMyTable'

    try
    {
        Invoke-RTRivet -Push -ErrorAction SilentlyContinue
        Assert-Error -Last 'not found'
    }
    finally
    {
        Remove-Item $badPluginPath
    }

}

