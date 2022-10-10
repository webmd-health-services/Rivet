
function Checkpoint-Migration
{
    <#
    .SYNOPSIS
    Checkpoints the current state of the database so that it can be re-created.

    .DESCRIPTION
    The `Checkpoint-Migration` function captures the state of a database after all migrations have been applied. The
    captured state is exported to a `schema.ps1` file that can be applied with Rivet to re-create that state of the
    database. Before capturing the current state, a Rivet Push is invoked to ensure all migrations have been applied.

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

        # The output path for the schema.ps1 file. If not provided the path will default to the same directory as the `rivet.json` file.
        [String] $OutputPath,

        # If a schema.ps1 script already exists at the output path it will be overwritten when Force is given.
        [Switch] $Force
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    [Rivet.Configuration.Configuration]$settings = Get-RivetConfig -Database $Database -Path $ConfigFilePath -Environment $Environment

    if( -not $OutputPath )
    {
        # If no output path put schema.ps1 file in same directory as the rivet.json file.
        $OutputPath = Join-Path -Path (Split-Path -Path $settings.Path) -ChildPath "schema.ps1"
    }

    if ( (Test-Path -Path $OutputPath) -and -not $Force )
    {
        Write-Error "Checkpoint output path ""$($OutputPath)"" already exists. Use the -Force switch to overwrite."
        return
    }

    $params = @{
        Database = $Database;
        Environment = $Environment;
        ConfigFilePath = $ConfigFilePath;
    }

    Write-Debug "Checkpoint-Migration: Invoke-Rivet -Push on database(s) ($($settings.Databases.Name -join ', '))"
    Invoke-Rivet -Push @params | Write-Debug

    Write-Debug "Checkpoint-Migration: Exporting migration on database(s) ($($settings.Databases.Name -join ', '))"
    $migration = Export-Migration -SqlServerName $settings.SqlServerName -Database $settings.Databases[0].Name
    $migration = $migration -join [Environment]::NewLine
    $migration | Out-File -FilePath $OutputPath
}
