
function New-PluginsRoot
{
    param(
        [string]
        $Prefix
    )

    Set-StrictMode -Version 'Latest'

    if( (Test-Path -Path 'TestDrive:') )
    {
        $tempDir = $TestDrive
    }
    else
    {
        $tempDir = New-TempDirectory -Prefix $Prefix
    }

    $rivetJson = Get-Content -Path $RTConfigFilePath -Raw | ConvertFrom-Json
    if( -not $rivetJson )
    {
        return
    }

    if( -not ($rivetJson | Get-Member -Name 'PluginsRoot') )
    {
        $rivetJson | Add-Member -MemberType NoteProperty -Name 'PluginsRoot' -Value $tempDir.FullName
    }

    $rivetJson.PluginsRoot = $tempDir.FullName

    $rivetJson | ConvertTo-Json -Depth 100 | Set-Content -Path $RTConfigFilePath

    return $tempDir
}