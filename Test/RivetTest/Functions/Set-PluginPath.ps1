
function Set-PluginPath
{
    param(
        [Parameter(Mandatory,ParameterSetName='PluginPaths')]
        # Path to any plugins that should get loaded in the test.
        [String[]]$PluginPath,

        [Parameter(Mandatory,ParameterSetName='PluginModules')]
        # Path to any modules that contain plug-ins.
        [String[]]$PluginModule,

        # Path to the rivet.json configuration file. Defaults to the one created by the RivetTest module.
        [String]$ConfigPath = $RTConfigFilePath
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

        $propertyName = $PSCmdlet.ParameterSetName
        $value = $PluginModule
        if( $propertyName -eq 'PluginPaths' )
        {
            $value = $PluginPath | Resolve-Path -Relative
        }

        if( -not ($rivetJson | Get-Member -Name $propertyName) )
        {
            $rivetJson | Add-Member -MemberType NoteProperty -Name $propertyName -Value ''
        }

        $rivetJson.$propertyName = $value

        $rivetJson | ConvertTo-Json -Depth 100 | Set-Content -Path $ConfigPath
    }
    finally
    {
        Pop-Location
    }
}