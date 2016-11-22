<#
.SYNOPSIS
Initializes your Rivet working directory for development.
#>
[CmdletBinding()]
param(
)

#Requires -Version 4
Set-StrictMode -Version 'Latest'

$moduleNames = @( 'Pester', 'Silk' )
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

    Save-Module -Name $moduleName -Path $PSScriptRoot

    $versionDir = Join-Path -Path $modulePath -ChildPath '*.*.*'
    if( (Test-Path -Path $versionDir -PathType Container) )
    {
        $versionDir = Get-Item -Path $versionDir
        Get-ChildItem -Path $versionDir -Force | Move-Item -Destination $modulePath -Verbose
        Remove-Item -Path $versionDir
    }
}
