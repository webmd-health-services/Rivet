<#
.SYNOPSIS
Gets the migrations for a given database.

.DESCRIPTION
This script exposes Rivet's internal migration objects so you can do cool things with them.  You're welcome.  Enjoy!

Each object returned represents one migration, and includes properties for the push and pop operations in that migration.

.OUTPUTS
Rivet.Migration.

.EXAMPLE
Get-Migration

Returns `Rivet.Migration` objects for each migration in each database.

.EXAMPLE
Get-Migration -Database StarWars

Returns `Rivet.Migration` objects for each migration in the `StarWars` database.
#>
[CmdletBinding()]
param(
    [string[]]
    # The database(s) to migrate. Optional.  Will operate on all databases otherwise.
    $Database,

    [string]
    # The environment you're working in.  Controls which settings Rivet loads from the `rivet.json` configuration file.
    $Environment,

    [string]
    # The path to the Rivet configuration file.  Default behavior is to look in the current directory for a `rivet.json` file.  See `about_Rivet_Configuration` for more information.
    $ConfigFilePath
)

Set-StrictMode -Version Latest
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

& (Join-Path -Path $PSScriptRoot -ChildPath 'Import-Rivet.ps1' -Resolve)

Get-Migration @PSBoundParameters
