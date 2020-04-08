
function New-File
{
    param(
        $Name,
        $Content
    )

    Set-StrictMode -Version 'Latest'

    $root = $TestDrive.FullName
    if( $RTTestRoot )
    {
        $root = $RTTestRoot
    }

    $path = Join-Path -Path $root -ChildPath $Name
    $directoryPath = $path | Split-Path
    if( -not (Test-Path -Path $directoryPath -PathType Container) )
    {
        New-Item -Path $directoryPath -ItemType 'Directory' | Out-Null
    }
    $Content | Set-Content -Path $path
}

Set-Alias -Name 'GivenFile' -Value 'New-File'