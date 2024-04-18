<#
.SYNOPSIS
A database migration tool for PowerShell.

.DESCRIPTION
Rivet is a database migration tool for SQL Server. Finally!

This script is the entry point for Rivet. It is used to create a new migration, and apply/revert migrations against a
database.

Called without any arguments, Rivet will shows this help topic.

.LINK
about_Rivet

.LINK
about_Rivet_Configuration

.LINK
about_Rivet_Migrations

.EXAMPLE
rivet.ps1 -New 'CreateTableStarships'

Creates a new `CreateTableStarships` migration in all databases.

.EXAMPLE
rivet.ps1 -Push

Applies all migrations.

.EXAMPLE
rivet.ps1 -Push 'CreateTableStarships'

Demonstrates how to apply a named migration. Don't include the timestamp. Wildcards are permitted.

*Be careful with this syntax!* If the named migration(s) depend on other migrations that haven't been run, the
migration will fail.

.EXAMPLE
rivet.ps1 -Pop

Reverts the last migration script.

.EXAMPLE
rivet.ps1 -Pop 5

Demonstrates how to revert multiple migrations. The last `-Count` migrations will be popped.

.EXAMPLE
rivet.ps1 -Pop 'AddTable'

Demonstrates how to pop a specific migration. Wildcards supported. Will match either the migration's name or ID.

.EXAMPLE
rivet.ps1 -Redo

Reverts the last migration script, then reapplies its. Equivalent to

    rivet.ps1 -Pop
    rivet.ps1 -Push

.EXAMPLE
rivet.ps1 -Push -Environment Production

Demonstrates how to migrate databases in a different environment. The `Production` environment should be specified in
the `rivet.json` configuration file.

.EXAMPLE
rivet.ps1 -DropDatabase

Demonstrates how to drop the database(s) for the current environment. Using this switch will require confirmation from
the user but it can be bypassed when given the -Force switch as well.
#>
[CmdletBinding(DefaultParameterSetName='ShowHelp', SupportsShouldProcess)]
param(
    # Creates a new migration.
    [Parameter(Mandatory, ParameterSetName='New')]
    [switch] $New,

    # Applies migrations.
    [Parameter(Mandatory, ParameterSetName='Push')]
    [switch] $Push,

    # Reverts migrations.
    [Parameter(Mandatory, ParameterSetName='Pop')]
    [Parameter(Mandatory, ParameterSetName='PopByCount')]
    [Parameter(Mandatory, ParameterSetName='PopByName')]
    [Parameter(Mandatory, ParameterSetName='PopAll')]
    [switch] $Pop,

    # Reverts a migration, then re-applies it.
    [Parameter(Mandatory, ParameterSetName='Redo')]
    [switch] $Redo,

    # The name of the migrations to create, push, or pop. Matches against the migration's ID, Name, or file name
    # (without extension). Wildcards permitted.
    [Parameter(Mandatory, ParameterSetName='New', Position=1)]
    [Parameter(ParameterSetName='Push', Position=1)]
    [Parameter(Mandatory, ParameterSetName='PopByName', Position=1)]
    [ValidateLength(1,241)]
    [String[]] $Name,

    # The number of migrations to pop. Default is 1.
    [Parameter(Mandatory, ParameterSetName='PopByCount', Position=1)]
    [UInt32] $Count = 1,

    # Pop all migrations
    [Parameter(Mandatory, ParameterSetName='PopAll')]
    [switch] $All,

    # Force popping a migration you didn't apply or that is old.
    [Parameter(ParameterSetName='Pop')]
    [Parameter(ParameterSetName='PopByCount')]
    [Parameter(ParameterSetName='PopByName')]
    [Parameter(ParameterSetName='PopAll')]
    [Parameter(ParameterSetName='DropDatabase')]
    [switch] $Force,

    # The database(s) to migrate. Optional. Will operate on all databases otherwise.
    [Parameter(ParameterSetName='New', Position=2)]
    [Parameter(ParameterSetName='Push')]
    [Parameter(ParameterSetName='Pop')]
    [Parameter(ParameterSetName='PopByCount')]
    [Parameter(ParameterSetName='PopByName')]
    [Parameter(ParameterSetName='PopAll')]
    [Parameter(ParameterSetName='Redo')]
    [Parameter(ParameterSetName='DropDatabase')]
    [Parameter(ParameterSetName='Checkpoint')]
    [String[]] $Database,

    # The environment you're working in. Controls which settings Rivet loads from the `rivet.json` configuration file.
    [String] $Environment,

    # The path to the Rivet configuration file. Default behavior is to look in the current directory for a `rivet.json`
    # file. See `about_Rivet_Configuration` for more information.
    [String] $ConfigFilePath,

    # Drops the database(s) for the current environment when given. User will be prompted for confirmation when used.
    [Parameter(ParameterSetName='DropDatabase')]
    [switch] $DropDatabase,

    # Checkpoints the current state of the database so that it can be re-created.
    [Parameter(ParameterSetName='Checkpoint')]
    [switch] $Checkpoint
)

#Requires -Version 5.1
Set-StrictMode -Version Latest

if( $PSCmdlet.ParameterSetName -eq 'ShowHelp' )
{
    Get-Help $PSCommandPath
    return
}

& (Join-Path -Path $PSScriptRoot -ChildPath Import-Rivet.ps1 -Resolve)

Invoke-Rivet @PSBoundParameters

exit $Error.Count
