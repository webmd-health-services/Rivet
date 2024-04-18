
function New-RivetJsonFile
{
    param(
        [Parameter(Mandatory)]
        [String] $In,

        [String] $SqlServerName,

        [String[]] $PluginPath,

        [String[]] $Database = @(),

        [UInt32] $CommandTimeout,

        [hashtable] $TargetDatabase,

        [String[]] $IgnoredDatabase,

        [UInt32] $ConnectionTimeout,

        [switch] $PassThru
    )

    Set-StrictMode -Version 'Latest'

    if (-not (Test-Path -Path $In))
    {
        New-Item -Path $In -ItemType Directory | Out-Null
    }

    if (-not $PSBoundParameters.ContainsKey('SqlServerName'))
    {
        $serverTxtPath = Join-Path -Path $script:moduleRoot -ChildPath '..\Server.txt' -Resolve
        $SqlServerName = Get-Content -Path $serverTxtPath -ReadCount 1
    }

    $rivetJson = [pscustomobject]@{
        SqlServerName = $SqlServerName;
        DatabasesRoot = 'Databases';
        Databases = $Database
    }

    if ($PSBoundParameters.ContainsKey('CommandTimeout'))
    {
        $rivetJson | Add-Member -Name 'CommandTimeout' -MemberType NoteProperty -Value $CommandTimeout
    }

    if ($PSBoundParameters.ContainsKey('TargetDatabase'))
    {
        $rivetJson |
            Add-Member -Name 'TargetDatabases' -MemberType NoteProperty -Value ([pscustomobject]$TargetDatabase)
    }

    if ($PSBoundParameters.ContainsKey('IgnoredDatabase'))
    {
        $rivetJson |
            Add-Member -Name 'IgnoreDatabases' -MemberType NoteProperty -Value $IgnoredDatabase
    }

    if ($PSBoundParameters.ContainsKey('ConnectionTimeout'))
    {
        $rivetJson |
            Add-Member -Name 'ConnectionTimeout' -MemberType NoteProperty -Value $ConnectionTimeout
    }

    $databasesPath = Join-Path -Path $In -ChildPath 'Databases'
    if (-not (Test-Path -Path $databasesPath))
    {
        New-Item -Path $databasesPath -ItemType Directory | Out-Null
    }

    foreach ($dbName in $Database)
    {
        $dbMigrationPath = Join-Path -Path $databasesPath -ChildPath "${dbName}\Migrations"
        if ((Test-Path -Path $dbMigrationPath))
        {
            continue
        }

        New-Item -Path $dbMigrationPath -ItemType Directory | Out-Null
    }

    if ($PluginPath)
    {
        $rivetJson | Add-Member -Name 'PluginPaths' -MemberType NoteProperty -Value $PluginPath
    }

    GivenFile 'rivet.json' -In $In -Content ($rivetJson | ConvertTo-Json -Depth 100) -PassThru:$PassThru
}

Set-Alias -Name 'GivenRivetJsonFile' -Value 'New-RivetJsonFile'
Set-Alias -Name 'GivenRivetJson' -Value 'New-RivetJsonFile'
