
function Initialize-Database
{
    <#
    .SYNOPSIS
    Intializes the database so that it can be migrated by Rivet.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [Rivet.Configuration.Configuration]
        $Configuration
    )

    Set-StrictMode -Version 'Latest'

    $who = ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME);
    $migrationsPath = Join-Path -Path $rivetModuleRoot -ChildPath 'Migrations'
    Write-Debug -Message ('# {0}.{1}' -f $Connection.DataSource,$Connection.Database)
    Update-Database -Path $migrationsPath -RivetSchema -Configuration $Configuration
}
