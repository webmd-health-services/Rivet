
function Get-MigrationFile
{
    <#
    .SYNOPSIS
    Gets the migration script files.
    #>
    [CmdletBinding()]
    [OutputType([IO.FileInfo])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='AllDatabases')]
        [Object] $InputObject,

        [Parameter(Mandatory, ParameterSetName='Internal')]
        [String] $DatabaseName,

        [Parameter(Mandatory, ParameterSetName='Internal')]
        [switch] $Internal,

        # A list of migrations to include. Matches against the migration's ID or Name or the migration's file name
        # (without extension). Wildcards permitted.
        [String[]] $Include,

        # A list of migrations to exclude. Matches against the migration's ID or Name or the migration's file name
        # (without extension). Wildcards permitted.
        [String[]] $Exclude,

        [switch] $Descending,

        [switch] $ForExecution
    )

    begin
    {
        Set-StrictMode -Version Latest
        Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

        Write-Timing -Message 'Get-MigrationFile  BEGIN' -Indent

        $foundMatches = @{}
        $Include |
            Where-Object { $_ } |
            Where-Object { -not [wildcardpattern]::ContainsWildcardCharacters($_) } |
            ForEach-Object { $foundMatches[$_] = $false }
    }

    process
    {
        if ($InputObject)
        {
            $DatabaseName = $InputObject.Name
            $Path = $InputObject.MigrationsRoot
        }

        # Get Rivet's internal migration scripts first.
        if ($ForExecution)
        {
            Get-MigrationFile -DatabaseName $DatabaseName -Internal | Write-Output
        }

        & {
                if ($Internal)
                {
                    $Path = $script:rivetInternalMigrationsPath
                }

                Write-Debug -Message $Path
                if( (Test-Path -Path $Path -PathType Container) )
                {
                    Get-ChildItem -Path $Path -Filter $script:schemaFileName -ErrorAction Ignore
                    return Get-ChildItem -Path $Path -Filter '*_*.ps1'
                }

                if( (Test-Path -Path $Path -PathType Leaf) )
                {
                    return Get-Item -Path $Path
                }
            } |
            ForEach-Object {
                $isBaseline = $false
                if( $_.BaseName -eq 'schema' )
                {
                    $id = $script:schemaMigrationId # midnight on year 1, month 0, day 0.
                    $name = $_.BaseName
                    $isBaseline = $true
                }
                elseif( $_.BaseName -notmatch '^(\d{14})_(.+)' )
                {
                    Write-Error ('Migration {0} has invalid name.  Must be of the form `YYYYmmddhhMMss_MigrationName.ps1' -f $_.FullName)
                    return
                }
                else
                {
                    $id = [int64]$matches[1]
                    $name = $matches[2]
                }

                $isRivetMigration = $id -lt $script:firstMigrationId

                $_ |
                    Add-Member -MemberType NoteProperty -Name 'MigrationID' -Value $id -PassThru |
                    Add-Member -MemberType NoteProperty -Name 'MigrationName' -Value $name -PassThru |
                    Add-Member -MemberType NoteProperty -Name 'DatabaseName' -Value $DatabaseName -PassThru |
                    Add-Member -MemberType NoteProperty -Name 'IsRivetMigration' -Value $isRivetMigration -PassThru |
                    Add-Member -Membertype NoteProperty -Name 'IsBaselineMigration' -Value $isBaseline -PassThru
            } |
            Where-Object {
                if (-not ($PSBoundParameters.ContainsKey('Include')))
                {
                    return $true
                }

                $migration = $_
                foreach ($includeItem in $Include)
                {
                    $foundMatch = $migration.MigrationID -like $includeItem -or `
                                  $migration.MigrationName -like $includeItem -or `
                                  $migration.BaseName -like $includeItem
                    if ($foundMatch)
                    {
                        if ($foundMatches.ContainsKey($includeItem))
                        {
                            $foundmatches[$includeItem] = $true
                        }
                        return $true
                    }
                }
                return $false
            } |
            Where-Object {

                if( -not ($PSBoundParameters.ContainsKey( 'Exclude' )) )
                {
                    return $true
                }

                $migration = $_
                foreach( $pattern in $Exclude )
                {
                    $foundMatch = $migration.MigrationID -like $pattern -or `
                                  $migration.MigrationName -like $pattern -or `
                                  $migration.BaseName -like $pattern
                    if( $foundMatch )
                    {
                        return $false
                    }
                }

                return $true
            } |
            Where-Object {
                if ($Internal)
                {
                    return $true
                }

                if ($_.IsRivetMigration -and -not $_.IsBaselineMigration)
                {
                    $msg = "Migration '$($_.FullName)' has invalid ID ""$($_.MigrationID)"". IDs lower than $($script:firstMigrationId) " +
                           'are reserved for Rivet''s internal use.'
                    Write-Error $msg -ErrorAction Stop
                    return $false
                }
                return $true
            } |
            Sort-Object -Property 'MigrationID' -Descending:$Descending |
            Write-Output
    }

    end
    {
        foreach ($includeItem in $foundMatches.Keys)
        {
            if ($foundMatches[$includeItem])
            {
                continue
            }

            $msg = "Failed to get migration file ""${includeItem}"" because a migration file with that ID, name, " +
                   "or base file name does not exist in ""${Path}""."
            Write-Error $msg -ErrorAction Stop
        }

        Write-Timing -Message 'Get-MigrationFile  BEGIN' -Outdent
    }
}
