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

$rivetTestPsd1Path = Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest.psd1' -Resolve

$rivetRoot = @( '..\..\Rivet', '..\..' ) |
                ForEach-Object { Join-Path -Path $PSScriptRoot -ChildPath $_ -Resolve -ErrorAction Ignore } |
                Where-Object { (Test-Path -Path (Join-Path -Path $_ -ChildPath 'Import-Rivet.ps1') ) } |
                Select-Object -First 1

if( (Test-Path -Path 'env:APPVEYOR') )
{
    if( -not (Get-Module 'Rivet') )
    {
        & (Join-Path -Path $PSScriptRoot -ChildPath '..\..\Rivet\Import-Rivet.ps1' -Resolve)
    }

    if( -not (Get-Module 'RivetTest') )
    {
        Import-Module -Name $rivetTestPsd1Path -ArgumentList $rivetRoot
    }
}
else
{
    & (Join-Path -Path $PSScriptRoot -ChildPath '..\..\Rivet\Import-Rivet.ps1' -Resolve)
    Import-Module -Name $rivetTestPsd1Path -Force -ArgumentList $rivetRoot
}
