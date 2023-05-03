
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
        $schemaPs1Path = Join-Path -Path $databaseItem.MigrationsRoot -ChildPath $script:schemaFileName

        $schemaPs1Exists = Test-Path -Path $schemaPs1Path
        if (($schemaPs1Exists) -and -not $Force)
        {
            Write-Error "Checkpoint output path ""$($schemaPs1Path)"" already exists. Use the -Force switch to overwrite."
            return
        }

        $databaseName = $databaseItem.Name
        Write-Debug "Checkpoint-Migration: Exporting migration on database ${databaseName}"
        $migration = Export-Migration -Session $Session -Database $databaseItem.Name -Checkpoint
        $migration = $migration -join [Environment]::NewLine
        Set-Content -Path $schemaPs1Path -Value $migration

        if (-not $schemaPs1Exists)
        {
            $displayPath = $schemaPs1Path | Resolve-Path -Relative
            if ($displayPath -match '\.\.[\\/]')
            {
                $displayPath = $schemaPs1Path
            }
            if ($displayPath -match '\s')
            {
                $displayPath = """${displayPath}"""
            }

            $displayName = $databaseName
            if ($displayName -match '\s')
            {
                $displayName = """${displayName}"""
            }
            $msg = "Rivet created the ${displayName} database's baseline schema file ${displayPath}. Please check " +
                   'this file into source control.'
            Write-Information $msg -InformationAction Continue
        }
    }
}
