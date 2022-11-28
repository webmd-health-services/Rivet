
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
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $who = ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME);
    $migrationPaths = [System.Collections.ArrayList]::new()
    $rivetMigrationsPath = Join-Path -Path $rivetModuleRoot -ChildPath 'Migrations'
    $migrationPaths.Add($rivetMigrationsPath) | Out-Null
    Write-Debug -Message ('# {0}.{1}' -f $Connection.DataSource,$Connection.Database)

    # Add schema.ps1 file from database's migration directory if it exists
    $databaseItem = $Configuration.Databases | Where-Object {$_.Name -eq $Connection.Database}
    $schemaFilePath = Join-Path -Path $databaseItem.MigrationsRoot -ChildPath 'schema.ps1'
    if( (Test-Path -Path $schemaFilePath) )
    {
        $migrationPaths.Add($schemaFilePath) | Out-Null
    }

    Update-Database -Path $migrationPaths -RivetSchema -Configuration $Configuration
}
