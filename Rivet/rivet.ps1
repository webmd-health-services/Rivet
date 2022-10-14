<#
.SYNOPSIS
A database migration tool for PowerShell.

.DESCRIPTION
Rivet is a database migration tool for SQL Server.  Finally!

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

Demonstrates how to revert multiple migrations.  The last `-Count` migrations will be popped.

.EXAMPLE
rivet.ps1 -Pop 'AddTable'

Demonstrates how to pop a specific migration.  Wildcards supported.  Will match either the migration's name or ID.

.EXAMPLE
rivet.ps1 -Redo

Reverts the last migration script, then reapplies its.  Equivalent to 

    rivet.ps1 -Pop
    rivet.ps1 -Push

.EXAMPLE
rivet.ps1 -Push -Environment Production

Demonstrates how to migrate databases in a different environment.  The `Production` environment should be specified in the `rivet.json` configuration file.

.EXAMPLE
rivet.ps1 -DropDatabase

Demonstrates how to drop the database(s) for the current environment. Using this switch will require confirmation from the user but it can be bypassed when given the -Force switch as well.
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
    [Parameter(Mandatory=$true,ParameterSetName='PopByCount')]
    [Parameter(Mandatory=$true,ParameterSetName='PopByName')]
    [Parameter(Mandatory=$true,ParameterSetName='PopAll')]
    [Switch]
    # Reverts migrations.
    $Pop,
    
    [Parameter(Mandatory=$true,ParameterSetName='Redo')]
    [Switch]
    # Reverts a migration, then re-applies it.
    $Redo,

    [Parameter(Mandatory=$true,ParameterSetName='New',Position=1)]
    [Parameter(ParameterSetName='Push',Position=1)]
    [Parameter(Mandatory=$true,ParameterSetName='PopByName',Position=1)]
    [ValidateLength(1,241)]
    [string[]]
    # The name of the migrations to create, push, or pop. Matches against the migration's ID, Name, or file name (without extension). Wildcards permitted.
    $Name,
    
    [Parameter(Mandatory=$true,ParameterSetName='PopByCount',Position=1)]
    [UInt32]
    # The number of migrations to pop. Default is 1.
    $Count = 1,

    [Parameter(Mandatory=$true,ParameterSetName='PopAll')]
    [Switch]
    # Pop all migrations
    $All,

    [Parameter(ParameterSetName='Pop')]
    [Parameter(ParameterSetName='PopByCount')]
    [Parameter(ParameterSetName='PopByName')]
    [Parameter(ParameterSetName='PopAll')]
    [Parameter(ParameterSetName='DropDatabase')]
    [Switch]
    # Force popping a migration you didn't apply or that is old.
    $Force,

    [Parameter(ParameterSetName='New',Position=2)]
    [Parameter(ParameterSetName='Push')]
    [Parameter(ParameterSetName='Pop')]
    [Parameter(ParameterSetName='PopByCount')]
    [Parameter(ParameterSetName='PopByName')]
    [Parameter(ParameterSetName='PopAll')]
    [Parameter(ParameterSetName='Redo')]
    [Parameter(ParameterSetName='DropDatabase')]
    [Parameter(ParameterSetName='Checkpoint')]
    [Parameter(ParameterSetName='Initialize')]
    [string[]]
    # The database(s) to migrate. Optional.  Will operate on all databases otherwise.
    $Database,

    [Parameter(ParameterSetName='New')]
    [Parameter(ParameterSetName='Push')]
    [Parameter(ParameterSetName='Pop')]
    [Parameter(ParameterSetName='PopByCount')]
    [Parameter(ParameterSetName='PopByName')]
    [Parameter(ParameterSetName='PopAll')]
    [Parameter(ParameterSetName='Redo')]
    [Parameter(ParameterSetName='DropDatabase')]
    [Parameter(ParameterSetName='Checkpoint')]
    [Parameter(ParameterSetName='Initialize')]
    [string]
    # The environment you're working in.  Controls which settings Rivet loads from the `rivet.json` configuration file.
    $Environment,

    [Parameter(ParameterSetName='New')]
    [Parameter(ParameterSetName='Push')]
    [Parameter(ParameterSetName='Pop')]
    [Parameter(ParameterSetName='PopByCount')]
    [Parameter(ParameterSetName='PopByName')]
    [Parameter(ParameterSetName='PopAll')]
    [Parameter(ParameterSetName='Redo')]
    [Parameter(ParameterSetName='DropDatabase')]
    [Parameter(ParameterSetName='Checkpoint')]
    [Parameter(ParameterSetName='Initialize')]
    [string]
    # The path to the Rivet configuration file.  Default behavior is to look in the current directory for a `rivet.json` file.  See `about_Rivet_Configuration` for more information.
    $ConfigFilePath,

    [Parameter(ParameterSetName='DropDatabase')]
    [Switch]
    # Drops the database(s) for the current environment when given. User will be prompted for confirmation when used.
    $DropDatabase,

    [Parameter(ParameterSetName='Checkpoint')]
    [Switch]
    # Checkpoints the current state of the database so that it can be re-created.
    $Checkpoint,

    [Parameter(ParameterSetName='Checkpoint')]
    [String]
    # The output path for the schema.ps1 file that will be generated when using the -Checkpoint switch. If not provided the path will default to the same directory as the `rivet.json` file.
    $CheckpointOutputPath,

    [Parameter(ParameterSetName='Initialize')]
    [Switch]
    # Initializes a database for a migration by applying contents of the schema.ps1 file located at the same directory as the rivet.json file.
    $Initialize
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
