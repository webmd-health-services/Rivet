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

Set-StrictMode -Version Latest
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

if( (Get-Module RivetTest) )
{
    Remove-Module RivetTest
}

Import-Module (Join-Path $PSScriptRoot RivetTest.psd1 -Resolve) -ArgumentList $DatabaseName -ErrorAction Stop
