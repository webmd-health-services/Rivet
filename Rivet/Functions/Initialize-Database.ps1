
function Initialize-Database
{
    <#
    .SYNOPSIS
    Intializes the database so that it can be migrated by Rivet.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Rivet_Session] $Session
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $migrationPaths = [Collections.ArrayList]::New()
    $rivetMigrationsPath = Join-Path -Path $rivetModuleRoot -ChildPath 'Migrations'
    $migrationPaths.Add($rivetMigrationsPath) | Out-Null
    Write-Debug -Message ('# {0}.{1}' -f $Session.Connection.DataSource,$Session.Connection.Database)

    # Add schema.ps1 file from database's migration directory if it exists
    $databaseItem = $Session.CurrentDatabase
    $schemaFilePath = Join-Path -Path $databaseItem.MigrationsRoot -ChildPath 'schema.ps1'
    if( (Test-Path -Path $schemaFilePath) )
    {
        $migrationPaths.Add($schemaFilePath) | Out-Null
    }

    Update-Database -Path $migrationPaths -RivetSchema -Session $Session
}
