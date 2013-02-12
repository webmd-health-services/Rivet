<#
.SYNOPSIS
Imports the Pstep module.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]
    # The name of the SQL Server to connect to.
    $SqlServerName,
    
    [Parameter(Mandatory=$true)]
    [string]
    # The name of the database to synchronize/migrate.
    $Database
)

Set-StrictMode -Version Latest
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

if( (Get-Module Pstep) )
{
    Remove-Module Pstep
}

Import-Module $PSScriptRoot -ArgumentList $SqlServerName,$Database