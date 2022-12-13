
function Checkpoint-Migration
{
    <#
    .SYNOPSIS
    Checkpoints the current state of the database so that it can be re-created.

    .DESCRIPTION
    The `Checkpoint-Migration` function captures the state of a database after all migrations have been applied. The
    captured state is exported to a `schema.ps1` file that can be applied with Rivet to re-create that state of the
    database. Migrations must be pushed before they can be checkpointed.

    .EXAMPLE
    Checkpoint-Migration -Database $Database -Environment $Environment -ConfigFilePath $ConfigFilePath

    Demonstrates how to checkpoint a migration.
    #>
    [CmdletBinding()]
    param(
        # The database(s) to migrate.
        [Parameter(Mandatory)]
        [String[]] $Database,

        # The environment you're working in.
        [String] $Environment,

        # The path to the Rivet configuration file. Default behavior is to look in the current directory for a `rivet.json` file.
        [String] $ConfigFilePath,

        # If a schema.ps1 script already exists at the output path it will be overwritten when Force is given.
        [Switch] $Force
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    [Rivet.Configuration.Configuration]$settings = Get-RivetConfig -Database $Database -Path $ConfigFilePath -Environment $Environment

    foreach( $databaseItem in $settings.Databases )
    {
        $OutputPath = Join-Path -Path $databaseItem.MigrationsRoot -ChildPath "schema.ps1"

        if ( (Test-Path -Path $OutputPath) -and -not $Force )
        {
            Write-Error "Checkpoint output path ""$($OutputPath)"" already exists. Use the -Force switch to overwrite."
            return
        }

        $query = @"
        SELECT CONCAT( FORMAT(ID, '00000000000000'), '_', Name) as MigrationFileName
        FROM rivet.Migrations
        WHERE ID > $($script:firstMigrationId)
"@

        try
        {
            Connect-Database -SqlServerName $settings.SqlServerName `
                            -Database $databaseItem.Name `
                            -ConnectionTimeout $settings.ConnectionTimeout

            $pushedMigrations = Invoke-Query -Query $query
        }
        finally
        {
            Disconnect-Database
        }

        Write-Debug "Checkpoint-Migration: Exporting migration on database $($databaseItem.Name)"
        $migration = Export-Migration -SqlServerName $settings.SqlServerName -Database $databaseItem.Name -ConfigFilePath $ConfigFilePath
        $migration = $migration -join [Environment]::NewLine
        Set-Content -Path $OutputPath -Value $migration

        foreach( $migration in $pushedMigrations )
        {
            $migrationFilePath = Join-Path -Path $databaseItem.MigrationsRoot -ChildPath "$($migration.MigrationFileName).ps1"
            Remove-Item -Path $migrationFilePath
        }
    }
}
