<#
.SYNOPSIS
Imports the RivetTest module.
#>
[CmdletBinding()]
param(
    [Switch]
    $Force
)

#Requires -Version 4
Set-StrictMode -Version 'Latest'

Write-Debug -Message ('PSScriptRoot: {0}' -f $PSScriptRoot)
Write-Debug -Message ('PSCommandPath: {0}' -f $PSCommandPath)
$rivetRoot = @( '..\..\Rivet', '..\..' ) |
                ForEach-Object { Join-Path -Path $PSScriptRoot -ChildPath $_ -Resolve -ErrorAction Ignore } |
                Where-Object { (Test-Path -Path (Join-Path -Path $_ -ChildPath 'Import-Rivet.ps1') ) } |
                Select-Object -First 1

& (Join-Path -Path $rivetRoot -ChildPath 'Import-Rivet.ps1' -Resolve)

$rivetTestPsd1Path = Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest.psd1' -Resolve

$startedAt = Get-Date
$loadedModule = Get-Module -Name 'RivetTest'
if( $loadedModule )
{
    if( -not $Force -and $loadedModule.Path -notlike ('{0}\*'-f $PSScriptRoot) )
    {
        Write-Verbose ('Reloading RivetTest module. Currently loaded from {0}, but need to re-load from {1}.' -f $loadedModule.Path, $PSScriptRoot) -Verbose
        $Force = $true
    }

    if( -not $Force -and ($loadedModule | Get-Member 'ImportedAt') )
    {
        $importedAt = $loadedModule.ImportedAt
        $newFiles = Get-ChildItem -Path $PSScriptRoot -File -Recurse |
                        Where-Object { $_.LastWriteTime -gt $importedAt }
        if( $newFiles )
        {
            Write-Verbose ('Reloading RivetTest module. The following files were modified since {0}:{1} * {2}' -f $importedAt,([Environment]::NewLine),($newFiles -join ('{0} * ' -f ([Environment]::NewLine)))) -Verbose
            $Force = $true
        }
    }

    $thisModuleManifest = Test-ModuleManifest -Path $rivetTestPsd1Path
    if( $thisModuleManifest )
    {
        if( -not $Force -and $thisModuleManifest.Version -ne $loadedModule.Version )
        {
            Write-Verbose ('Reloading RivetTest module. Module from {0} at version {1} not equal to module from {2} at version {3}.' -f $loadedModule.ModuleBase,$loadedModule.Version,(Split-Path -Parent -Path $thisModuleManifest.Path),$thisModuleManifest.Version) -Verbose
            $Force = $true
        }
    }
}
else
{
    $Force = $true
}

if( -not $Force )
{
    return
}

$importModuleParams = @{ }

if( $Force -and $loadedModule )
{
    # Remove so we don't get errors about conflicting type data.
    Remove-Module -Name 'RivetTest' -Verbose:$false -WhatIf:$false
}

Write-Verbose ('Importing RivetTest ({0}).' -f $rivetTestPsd1Path)
Import-Module $rivetTestPsd1Path -ArgumentList $rivetRoot -ErrorAction Stop -Verbose:$false @importModuleParams

if( -not (Get-Module -Name 'RivetTest' | Get-Member -Name 'ImportedAt') )
{
    Get-Module -Name 'RivetTest' | Add-Member -MemberType NoteProperty -Name 'ImportedAt' -Value (Get-Date)
}

if( $Force )
{
    $loadedModule = Get-Module -Name 'RivetTest'
    $loadedModule.ImportedAt = Get-Date
}
