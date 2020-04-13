
function Set-PluginPath
{
    param(
        [Parameter(Mandatory)]
        [string[]]
        # Path to any plugins that should get loaded in the test.
        $PluginPath,

        [string]
        # Path to the rivet.json configuration file. Defaults to the one created by the RivetTest module.
        $ConfigPath = $RTConfigFilePath
    )

    Set-StrictMode -Version 'Latest'

    $configRoot = $ConfigPath | Split-Path -Parent
    # So we can have Resolve-Path -Relative work.
    Push-Location $configRoot
    try
    {
        $rivetJson = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        if( -not $rivetJson )
        {
            return
        }

        if( -not ($rivetJson | Get-Member -Name 'PluginPaths') )
        {
            $rivetJson | Add-Member -MemberType NoteProperty -Name 'PluginPaths' -Value ''
        }

        $rivetJson.PluginPaths = $PluginPath | Resolve-Path -Relative

        $rivetJson | ConvertTo-Json -Depth 100 | Set-Content -Path $ConfigPath
    }
    finally
    {
        Pop-Location
    }
}