
function New-TestMigration
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        # The migration contents to output.
        $InputObject,

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the migration.
        $Name,

        [string]
        # The name of the database.
        $DatabaseName = $RTDatabaseName,

        [string]
        $ConfigFilePath = $RTConfigFilePath
    )

    Set-StrictMode -Version 'Latest'

    $config = Get-RivetConfig -Path $ConfigFilePath -Database $DatabaseName
    $migrationsRoot = Join-Path -Path $config.DatabasesRoot -ChildPath ('{0}\Migrations' -f $DatabaseName)
    if( -not (Test-Path -Path $migrationsRoot -PathType Container) )
    {
        New-Item -Path $migrationsRoot -ItemType 'Directory' -Force | Format-Table | Out-String | Write-Verbose
    }

    do
    {
        $script:RTTimestamp++
        $migrationPath = '{0}_{1}.ps1' -f $RTTimestamp,$Name
        $migrationPath = Join-Path -Path $migrationsRoot -ChildPath $migrationPath
    }
    while( (Test-Path -Path $migrationPath -PathType Leaf) )

    $InputObject | Set-Content -Path $migrationPath
    Get-Item -Path $migrationPath
}
