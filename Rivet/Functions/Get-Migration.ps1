
function Get-Migration
{
    <#
    .SYNOPSIS
    Gets the migrations for all or specific databases.

    .DESCRIPTION
    The `Get-Migration` function returns `Rivet.Migration` objects for all the migrations in all or specific
    databases.With no parameters, looks in the current directory for a `rivet.json` file and returns all the migrations
    for all the databases based on that configuration. Use the `ConfigFilePath` to load and use a specific `rivet.json`
    file.

    You can return migrations from specific databases by passing those database names as values to the `Database`
    parameter.

    The `Environment` parameter is used to load the correct environment-specific settings from the `rivet.json` file.

    You can filter what migrations are returned using the `Include` or `Exclude` parameters, which support wildcards,
    and will match any part of the migration's filename, including the ID.

    Use the `Before` and `After` parameters to return migrations whose timestamps/IDs come before and after the given
    dates.

    .OUTPUTS
    Rivet.Migration.

    .EXAMPLE
    Get-Migration

    Returns `Rivet.Migration` objects for each migration in each database.

    .EXAMPLE
    Get-Migration -Database StarWars

    Returns `Rivet.Migration` objects for each migration in the `StarWars` database.

    .EXAMPLE
    Get-Migration -Include 'CreateDeathStarTable','20150101000648','20150101150448_CreateRebelBaseTable','*Hoth*','20150707*'

    Demonstrates how to get use the `Include` parameter to find migrations by name, ID, or file name. In this case, the
    following migrations will be returned:

     * The migration whose name is `CreateDeathStarTable`.
     * The migration whose ID is `20150101000648`.
     * The migration whose full name is `20150101150448_CreateRebelBaseTable`.
     * Any migration whose contains `Hoth`.
     * Any migration created on July 7th, 2015.

    .EXAMPLE
    Get-Migration -Exclude 'CreateDeathStarTable','20150101000648','20150101150448_CreateRebelBaseTable','*Hoth*','20150707*'

    Demonstrates how to get use the `Exclude` parameter to skip/not return certain migrations by name, ID, or file name.
    In this case, the following migrations will be *not* be returned:

     * The migration whose name is `CreateDeathStarTable`.
     * The migration whose ID is `20150101000648`.
     * The migration whose full name is `20150101150448_CreateRebelBaseTable`.
     * Any migration whose contains `Hoth`.
     * Any migration created on July 7th, 2015.
    #>
    [CmdletBinding(DefaultParameterSetName='External')]
    [OutputType([Rivet.Migration])]
    param(
        # The database names whose migrations to get. The default is to get migrations from all databases.
        [Parameter(ParameterSetName='External')]
        [String[]] $Database,

        # The environment settings to use.
        [Parameter(ParameterSetName='External')]
        [String] $Environment,

        # The path to the rivet.json file to use. Defaults to `rivet.json` in the current directory.
        [Parameter(ParameterSetName='External')]
        [String] $ConfigFilePath,

        # A list of migrations to include. Matches against the migration's ID or Name or the migration's file name
        # (without extension). Wildcards permitted.
        [String[]] $Include,

        # A list of migrations to exclude. Matches against the migration's ID or Name or the migration's file name
        # (without extension). Wildcards permitted.
        [String[]] $Exclude,

        # Only get migrations before this date.  Default is all.
        [DateTime] $Before,

        # Only get migrations after this date.  Default is all.
        [DateTime] $After
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    Write-Timing -Message 'Get-Migration  BEGIN' -Indent

    function Clear-Migration
    {
        ('function:Push-Migration','function:Pop-Migration') |
            Where-Object { Test-Path -Path $_ } |
            Remove-Item -WhatIf:$false -Confirm:$false
    }

    Clear-Migration

    Write-Timing -Message 'Get-Migration  Clear-Migration'

    $session = New-RivetSession -ConfigurationPath $ConfigFilePath -Environment $Environment -Database $Database
    if( -not $session )
    {
        return
    }

    if ($null -eq $Database)
    {
        $Database = @()
    }

    $getMigrationFileParams = @{}
    if ($PSBoundParameters.ContainsKey('Include'))
    {
        $getMigrationFileParams['Include'] = $Include
    }

    if ($PSBoundParameters.ContainsKey('Exclude'))
    {
        $getMigrationFileParams['Exclude'] = $Exclude
    }

    $session.Databases |
        Where-Object {
            if (-not $Database.Length)
            {
                return $true
            }

            return $_.Name -in $Database
        } |
        Get-MigrationFile @getMigrationFileParams |
        Where-Object {
            if ($PSBoundParameters.ContainsKey('Before'))
            {
                $beforeTimestamp = [uint64]$Before.ToString('yyyyMMddHHmmss')
                if( $_.MigrationID -gt $beforeTimestamp )
                {
                    return $false
                }
            }

            if ($PSBoundParameters.ContainsKey('After'))
            {
                $afterTimestamp = [uint64]$After.ToString('yyyyMMddHHmmss')
                if( $_.MigrationID -lt $afterTimestamp )
                {
                    return $false
                }
            }
            return $true
        } |
        Convert-FileInfoToMigration -Session $session |
        Write-Output

    Write-Timing -Message 'Get-Migration  END' -Outdent
}