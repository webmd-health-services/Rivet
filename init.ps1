<#
.SYNOPSIS
Initializes your Rivet working directory for development.
#>
[CmdletBinding()]
param(
    [string]
    # The name of the SQL Server tests should run against. Ignored if running under AppVeyor.
    $SqlServerName
)

#Requires -Version 4
Set-StrictMode -Version 'Latest'

if( (Test-Path -Path 'env:APPVEYOR') )
{
    $SqlServerName = '.\SQL2012SP1'
}

if( $SqlServerName )
{
    $SqlServerName | Set-Content -Path 'Test\Server.txt'
}
