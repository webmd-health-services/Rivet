<#
.SYNOPSIS
A database migration tool for PowerShell.

.DESCRIPTION
Rivet is a database migration tool for PowerShell.  Finally!  
#>
[CmdletBinding()]
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
    # The name of the migration to create/push.  Wildcards accepted when pushing/popping.
    $Name,
    
    [Parameter(ParameterSetName='Pop',Position=1)]
    [UInt32]
    # The number of migrations to pop. Default
    $Count = 1,
    
    [Parameter(Mandatory=$true,ParameterSetName='Push')]
    [Parameter(Mandatory=$true,ParameterSetName='Pop')]
    [Parameter(Mandatory=$true,ParameterSetName='Redo')]
    [string]
    # The SQL Server to connect to, e.g. `.\Instance`.
    $SqlServerName,
    
    [Parameter(Mandatory=$true,ParameterSetName='New',Position=2)]
    [Parameter(Mandatory=$true,ParameterSetName='Push')]
    [Parameter(Mandatory=$true,ParameterSetName='Pop')]
    [Parameter(Mandatory=$true,ParameterSetName='Redo')]
    [string[]]
    # The databases to migrate.
    $Database,
    
    [Parameter(Mandatory=$true,ParameterSetName='New',Position=3)]
    [Parameter(Mandatory=$true,ParameterSetName='Push')]
    [Parameter(Mandatory=$true,ParameterSetName='Pop')]
    [Parameter(Mandatory=$true,ParameterSetName='Redo')]
    [string]
    # The directory where the database scripts are kept.  If `$Database` is singular, migrations are assumed to be in `$Path\$Database\Migrations`.  If `$Database` contains multiple items, `$Path` is assumed to point to a directory which contains directories for each database (e.g. `$Path\$Database[$i]`) and migrations are assumed to be in `$Path\$Database[$i]\Migrations`.
    $Path,

    [Parameter(Mandatory=$true,ParameterSetName='Help')]
    [Switch]
    # Display Help.
    $Help,

    [Parameter(ParameterSetName='Push')]
    [Parameter(ParameterSetName='Pop')]
    [Parameter(ParameterSetName='Redo')]
    [UInt32]
    # The time (in seconds) to wait for a connection to open. The default is 15 seconds.
    $ConnectionTimeout = 15
)

Set-StrictMode -Version Latest
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

if( (Get-Module Rivet) )
{
    Remove-Module Rivet
}
    
Import-Module $PSScriptRoot

Invoke-Rivet @PSBoundParameters

exit $error.Count
