
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
        [Parameter(Mandatory, ParameterSetName='WithSession')]
        [Rivet_Session] $Session,

        # The database(s) to migrate.
        [Parameter(Mandatory, ParameterSetName='WithoutSession')]
        [String[]] $Database,

        # The environment you're working in.
        [Parameter(ParameterSetName='WithoutSession')]
        [String] $Environment,

        # The path to the Rivet configuration file. Default behavior is to look in the current directory for a `rivet.json` file.
        [Parameter(ParameterSetName='WithoutSession')]
        [String] $ConfigFilePath,

        # If a schema.ps1 script already exists at the output path it will be overwritten when Force is given.
        [Switch] $Force
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    if ($PSCmdlet.ParameterSetName -eq 'WithoutSession')
    {
        $Session = New-RivetSession -ConfigurationPath $ConfigFilePath -Environment $Environment -Database $Database
    }

    foreach( $databaseItem in $Session.Databases )
    {
        $OutputPath = Join-Path -Path $databaseItem.MigrationsRoot -ChildPath "schema.ps1"

        if ((Test-Path -Path $OutputPath) -and -not $Force)
        {
            Write-Error "Checkpoint output path ""$($OutputPath)"" already exists. Use the -Force switch to overwrite."
            return
        }

        Write-Debug "Checkpoint-Migration: Exporting migration on database $($databaseItem.Name)"
        $migration = Export-Migration -Session $Session -Database $databaseItem.Name -Checkpoint
        $migration = $migration -join [Environment]::NewLine
        Set-Content -Path $OutputPath -Value $migration
    }
}
