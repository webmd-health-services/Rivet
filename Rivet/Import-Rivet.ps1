<#
.SYNOPSIS
Imports the Rivet module.

.DESCRIPTION
When writing migrations, it can be helpful to get intellisense.  In order to do so, you'll need to import Rivet.

.EXAMPLE
Import-Rivet.ps1

Demonstrates how to import the Rivet module.
#>
[CmdletBinding()]
param(
)

Set-StrictMode -Version Latest
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

if( (Get-Module Rivet) )
{
    Remove-Module Rivet -verbose:$false
}

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath Rivet.psd1 -Resolve) -verbose:$false
