<#
.SYNOPSIS
A database migration tool for PowerShell.

.DESCRIPTION
Pstep (pronounced `/step/`, the "p" is silent, as in "pterodactyl"), a database migration tool for PowerShell.  Finally!  
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
    
    [Parameter(Mandatory=$true,ParameterSetName='PopByName')]
    [Parameter(Mandatory=$true,ParameterSetName='PopByCount')]
    [Switch]
    # Reverts migrations.
    $Pop,
    
    [Parameter(Mandatory=$true,ParameterSetName='Redo')]
    [Switch]
    # Reverts a migration, then re-applies it.
    $Redo,

    [Parameter(Mandatory=$true,ParameterSetName='New',Position=1)]
    [Parameter(ParameterSetName='Push')]
    [Parameter(Mandatory=$true,ParameterSetName='PopByName')]
    [Parameter(ParameterSetName='Redo')]
    [string]
    # The name of the migration to create/push/pop/redo.  Wildcards accepted when pushing/popping.
    $Name,
    
    [Parameter(ParameterSetName='PopByCount')]
    [UInt32]
    # The number of migrations to pop.  Defaults to 1.
    $Count = 1,
    
    [Parameter(Mandatory=$true,ParameterSetName='Push')]
    [Parameter(Mandatory=$true,ParameterSetName='PopByName')]
    [Parameter(Mandatory=$true,ParameterSetName='PopByCount')]
    [Parameter(Mandatory=$true,ParameterSetName='Redo')]
    [string]
    # The SQL Server to connect to, e.g. `.\Instance`.
    $SqlServerName,
    
    [Parameter(Mandatory=$true,ParameterSetName='New',Position=2)]
    [Parameter(Mandatory=$true,ParameterSetName='Push')]
    [Parameter(Mandatory=$true,ParameterSetName='PopByName')]
    [Parameter(Mandatory=$true,ParameterSetName='PopByCount')]
    [Parameter(Mandatory=$true,ParameterSetName='Redo')]
    [string[]]
    # The databases to migrate.
    $Database,
    
    [Parameter(Mandatory=$true,ParameterSetName='New',Position=3)]
    [Parameter(Mandatory=$true,ParameterSetName='Push')]
    [Parameter(Mandatory=$true,ParameterSetName='PopByName')]
    [Parameter(Mandatory=$true,ParameterSetName='PopByCount')]
    [Parameter(Mandatory=$true,ParameterSetName='Redo')]
    [string]
    # The root directory where all scripts for all databases are kept.  Migrations are assumed to be in `$Path\$Database\Migrations`.
    $Path,
    
    [UInt32]
    # The time (in seconds) to wait for a connection to open. The default is 15 seconds.
    $ConnectionTimeout = 15
)

Set-StrictMode -Version Latest
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

if( (Get-Module Pstep) )
{
    Remove-Module Pstep
}
    
Import-Module $PSScriptRoot

try
{
    if( $pscmdlet.ParameterSetName -eq 'New' )
    {
        New-Migration -Name $Name -Database $Database -Path $Path
        exit $error.Count
    }

    $Database | ForEach-Object {

        Connect-Database -SqlServerName $SqlServerName -Database $_ -ConnectionTimeout $ConnectionTimeout
        
        try
        {
            Initialize-Database

            if( $pscmdlet.ParameterSetName -eq 'Push' )
            {
            }
            elseif( $pscmdlet.ParameterSetName -eq 'PopByCount' )
            {
            }
            elseif( $pscmdlet.ParameterSetName -eq 'PopByName' )
            {
            }
            elseif( $pscmdlet.ParameterSetName -eq 'Redo' )
            {
            }
        }
        catch
        {
        }
        finally
        {
            Disconnect-Database
        }
    }
}
finally
{
    Remove-Module Pstep
}

exit 0