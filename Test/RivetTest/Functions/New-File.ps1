
function New-File
{
    param(
        [Parameter(Mandatory, Position=0)]
        [String] $Name,

        [Parameter(Mandatory, Position=1)]
        [String] $Content,

        [String] $In,

        [switch] $PassThru
    )

    Set-StrictMode -Version 'Latest'

    if (-not $In)
    {
        if ($TestDrive | Get-Member 'FullName')
        {
            $In = $TestDrive.FullName
        }
        else
        {
            $In = $TestDrive
        }

        if( $RTTestRoot )
        {
            $In = $RTTestRoot
        }
    }

    $path = Join-Path -Path $In -ChildPath $Name
    $directoryPath = $path | Split-Path
    if( -not (Test-Path -Path $directoryPath -PathType Container) )
    {
        New-Item -Path $directoryPath -ItemType 'Directory' | Out-Null
    }
    $Content | Set-Content -Path $path

    if ($PassThru)
    {
        return $path
    }
}

Set-Alias -Name 'GivenFile' -Value 'New-File'