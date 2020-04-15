
function New-TestMigration
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        # The migration contents to output.
        [String]$InputObject,

        [Parameter(Mandatory)]
        [Alias('Name')]
        # The name of the migration.
        [String]$Named,

        # The name of the database.
        [String]$DatabaseName = $RTDatabaseName,

        [String]$ConfigFilePath = $RTConfigFilePath
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
        $migrationPath = '{0}_{1}.ps1' -f $RTTimestamp, $Named
        $migrationPath = Join-Path -Path $migrationsRoot -ChildPath $migrationPath
    }
    while( (Test-Path -Path $migrationPath -PathType Leaf) )

    $InputObject | Set-Content -Path $migrationPath
    Get-Item -Path $migrationPath
}

Set-Alias -Name 'GivenMigration' -Value 'New-TestMigration'
