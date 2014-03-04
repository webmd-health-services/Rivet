<#
.SYNOPSIS
Imports the RivetTest module.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]
    # The name of the test database to use.
    $DatabaseName
)

#Requires -Version 3
Set-StrictMode -Version 'Latest'

if( (Get-Module 'RivetTest') )
{
    Remove-Module 'RivetTest' -Verbose:$false
}

Import-Module (Join-Path $PSScriptRoot 'RivetTest.psd1' -Resolve) -ArgumentList $DatabaseName -ErrorAction Stop -Verbose:$false
