<#
.SYNOPSIS
Initializes your Rivet working directory for development.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    # The name of the SQL Server tests should run against.
    [String]$SqlServerName
)

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

$SqlServerName | Set-Content -Path 'Test\Server.txt'
