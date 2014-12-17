
function Initialize-Database
{
    <#
    .SYNOPSIS
    Intializes the database so that it can be migrated by Rivet.
    #>
    [CmdletBinding()]
    param(
    )

    Set-StrictMode -Version 'Latest'

    $who = ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME);
    $migrationsPath = Join-Path -Path $PSScriptRoot -ChildPath 'Migrations'
    Write-Host ('# {0}.{1}' -f $Connection.DataSource,$Connection.Database)
    Update-Database -Path $migrationsPath -DBScriptsPath $migrationsPath -RivetSchema
}
