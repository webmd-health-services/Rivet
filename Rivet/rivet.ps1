<#
.SYNOPSIS
A database migration tool for PowerShell.

.DESCRIPTION
Rivet is a database migration tool for PowerShell.  Finally!

This script is the entry point for Rivet.  It is used to create a new migration, and apply/revert migrations against a database.

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

Demonstrates how to apply a named migration.  Don't include the timestamp.  Wildcards are permitted.  

*Be careful with this syntax!*  If the named migration(s) depend on other migrations that haven't been run, the migration will fail.

.EXAMPLE
rivet.ps1 -Pop

Reverts the last migration script.

.EXAMPLE
rivet.ps1 -Pop 5

Demonstrates how to revert multiple migrations.

.EXAMPLE
rivet.ps1 -Redo

Reverts the last migration script, then reapplies its.  Equivalent to 

    rivet.ps1 -Pop
    rivet.ps1 -Push

.EXAMPLE
rivet.ps1 -Push -Environment Production

Demonstrates how to migrate databases in a different environment.  The `Production` environment should be specified in the `rivet.json` configuration file.
#>
#Requires -Version 3
[CmdletBinding(DefaultParameterSetName='ShowHelp', SupportsShouldProcess=$True)]
param(
    [Parameter(Mandatory=$true,ParameterSetName='New')]
    [Switch]
    # Creates a new migration.
    $New,
    
    [Parameter(Mandatory=$true,ParameterSetName='Push')]
    [Switch]
    # Applies migrations.
    $Push,
    
    [Parameter(Mandatory=$true,ParameterSetName='Pop')]
    [Switch]
    # Reverts migrations.
    $Pop,
    
    [Parameter(Mandatory=$true,ParameterSetName='Redo')]
    [Switch]
    # Reverts a migration, then re-applies it.
    $Redo,

    [Parameter(Mandatory=$true,ParameterSetName='New',Position=1)]
    [Parameter(ParameterSetName='Push',Position=1)]
    [string]
    # The name of the migration to create/push.  Wildcards accepted when pushing.
    $Name,
    
    [Parameter(ParameterSetName='Pop',Position=1)]
    [UInt32]
    # The number of migrations to pop. Default is 1.
    $Count = 1,

    [Parameter(ParameterSetName='PopAll')]
    [Switch]
    # Pop all migrations
    $Force,

    [Parameter(ParameterSetName='New',Position=2)]
    [Parameter(ParameterSetName='Push')]
    [Parameter(ParameterSetName='Pop')]
    [Parameter(ParameterSetName='PopAll')]
    [Parameter(ParameterSetName='Redo')]
    [string[]]
    # The database(s) to migrate. Optional.  Will operate on all databases otherwise.
    $Database,

    [Parameter(ParameterSetName='New')]
    [Parameter(ParameterSetName='Push')]
    [Parameter(ParameterSetName='Pop')]
    [Parameter(ParameterSetName='PopAll')]
    [Parameter(ParameterSetName='Redo')]
    [string]
    # The environment you're working in.  Controls which settings Rivet loads from the `rivet.json` configuration file.
    $Environment,

    [Parameter(ParameterSetName='New')]
    [Parameter(ParameterSetName='Push')]
    [Parameter(ParameterSetName='Pop')]
    [Parameter(ParameterSetName='PopAll')]
    [Parameter(ParameterSetName='Redo')]
    [string]
    # The path to the Rivet configuration file.  Default behavior is to look in the current directory for a `rivet.json` file.  See `about_Rivet_Configuration` for more information.
    $ConfigFilePath

)

Set-StrictMode -Version Latest

if( $PSCmdlet.ParameterSetName -eq 'ShowHelp' )
{
    Get-Help $PSCommandPath
    return
}

& (Join-Path -Path $PSScriptRoot -ChildPath Import-Rivet.ps1 -Resolve)

Invoke-Rivet @PSBoundParameters 

exit $error.Count
