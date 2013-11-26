<#
.SYNOPSIS
Imports the SqlPS module.
#>
[CmdletBinding()]
param(
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

if( (Get-Module SqlPS) )
{
    Remove-Module SqlPS
}

Import-Module (Join-Path $PSScriptRoot ..\SqlPS -Resolve) -DisableNameChecking