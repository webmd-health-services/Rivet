<#
.SYNOPSIS
Initializes your Rivet working directory for development.
#>
[CmdletBinding()]
param(
    [Switch]
    # Removes any previously downloaded packages and re-downloads them.
    $Clean
)

#Requires -Version 4
Set-StrictMode -Version 'Latest'

Get-ChildItem -Path 'env:' | Format-List | Out-String | Write-Verbose

Install-PackageProvider -Name NuGet -Force

$moduleNames = @( 'Pester', 'Silk', 'Carbon' )
foreach( $moduleName in $moduleNames )
{
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath $moduleName
    if( (Test-Path -Path $modulePath -PathType Container) )
    {
        if( $Clean )
        {
            Remove-Item -Path $modulePath -Recurse -Force
        }

        continue
    }

    Save-Module -Name $moduleName -Path $PSScriptRoot -Force

    $versionDir = Join-Path -Path $modulePath -ChildPath '*.*.*'
    if( (Test-Path -Path $versionDir -PathType Container) )
    {
        $versionDir = Get-Item -Path $versionDir
        Get-ChildItem -Path $versionDir -Force | Move-Item -Destination $modulePath -Verbose
        Remove-Item -Path $versionDir
    }
}

& (Join-Path -Path $PSScriptRoot -ChildPath 'Carbon\Import-Carbon.ps1' -Resolve)

$packagesRoot = Join-Path -Path $PSScriptRoot -ChildPath 'packages'

$nugetPath = Join-Path -Path $PSScriptRoot -ChildPath '.\Silk\bin\NuGet.exe' -Resolve
& $nugetPath install 'NUnit.Console' -OutputDirectory $packagesRoot

$linkPath = Join-Path -Path $packagesRoot -ChildPath 'NUnit.ConsoleRunner'
$targetPath = Get-ChildItem -Path $packagesRoot -Filter 'NUnit.ConsoleRunner.*.*.*' -Directory | 
                Where-Object { $_.IsJunction -eq $false } |
                Select-Object -ExpandProperty 'FullName'
Install-Junction -Link $linkPath -Target $targetPath

$sourceRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Source'
Get-ChildItem -Path $sourceRoot -Filter 'packages.config' -Recurse |
    ForEach-Object { & $nugetPath restore $_.FullName -SolutionDirectory $sourceRoot }