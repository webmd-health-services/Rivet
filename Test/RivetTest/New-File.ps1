
function New-File
{
    param(
        $Name,
        $Content
    )

    $path = Join-Path -Path $TestDrive.FullName -ChildPath $Name
    $directoryPath = $path | Split-Path
    if( -not (Test-Path -Path $directoryPath -PathType Container) )
    {
        New-Item -Path $directoryPath -ItemType 'Directory' | Out-Null
    }
    $Content | Set-Content -Path $path
}

Set-Alias -Name 'GivenFile' -Value 'New-File'