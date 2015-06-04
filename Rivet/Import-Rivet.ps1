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

#Requires -Version 4
Set-StrictMode -Version Latest

if( (Get-Module Rivet) )
{
    Remove-Module Rivet -Verbose:$false -Confirm:$false -WhatIf:$false
}

Import-Module (Join-Path -Path $PSScriptRoot -ChildPath Rivet.psd1 -Resolve) -Verbose:$false
