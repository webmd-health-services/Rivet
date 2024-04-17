
function New-TestMigration
{
    [CmdletBinding(DefaultParameterSetName='NamedMigration')]
    param(
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]
        # The migration contents to output.
        [String]$InputObject,

        [Parameter(Mandatory, ParameterSetName='NamedMigration')]
        [Alias('Name')]
        # The name of the migration.
        [String]$Named,

        # The name of the database.
        [String]$DatabaseName = $RTDatabaseName,

        [String]$ConfigFilePath = $RTConfigFilePath,

        [Parameter(Mandatory, ParameterSetName='SchemaPs1')]
        [switch] $AsCheckpoint
    )

    Set-StrictMode -Version 'Latest'

    $config = Get-RivetConfig -Path $ConfigFilePath -Database $DatabaseName
    $migrationsRoot = Join-Path -Path $config.DatabasesRoot -ChildPath ('{0}\Migrations' -f $DatabaseName)
    if( -not (Test-Path -Path $migrationsRoot -PathType Container) )
    {
        New-Item -Path $migrationsRoot -ItemType 'Directory' -Force | Format-Table | Out-String | Write-Verbose
    }

    if ($AsCheckpoint)
    {
        $migrationFileName = 'schema.ps1'
    }
    else
    {
        do
        {
            $script:RTTimestamp++
            $migrationFileName = "${script:RTTimestamp}_*.ps1"
            $migrationPath = Join-Path -Path $migrationsRoot -ChildPath $migrationFileName
        }
        while( (Test-Path -Path $migrationPath -PathType Leaf) )

        $migrationFileName = "${script:RTTimestamp}_${Named}.ps1"
    }

    $migrationPath = Join-Path -Path $migrationsRoot -ChildPath $migrationFileName
    $InputObject | Set-Content -Path $migrationPath
    $migrationFile = Get-Item -Path $migrationPath

    if (-not $AsCheckpoint)
    {
        $migrationFile |
            Add-Member -Name 'MigrationID' -MemberType NoteProperty -Value $script:RTTimestamp -PassThru |
            Add-Member -Name 'MigrationName' -MemberType NoteProperty -Value $Named
    }

    return $migrationFile
}

Set-Alias -Name 'GivenMigration' -Value 'New-TestMigration'
