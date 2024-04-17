
function Update-Database
{
    <#
    .SYNOPSIS
    Applies a set of migrations to the database.

    .DESCRIPTION
    By default, applies all unapplied migrations to the database.  You can reverse all migrations with the `Down` switch.

    .EXAMPLE
    Update-Database -Path C:\Projects\Rivet\Databases\Rivet\Migrations

    Applies all un-applied migrations from the `C:\Projects\Rivet\Databases\Rivet\Migrations` directory.

    .EXAMPLE
    Update-Database -Path C:\Projects\Rivet\Databases\Rivet\Migrations -Pop

    Reverses all migrations in the `C:\Projects\Rivet\Databases\Rivet\Migrations` directory
    #>
    [CmdletBinding(DefaultParameterSetName='Push', SupportsShouldProcess=$True)]
    param(
        [Parameter(Mandatory)]
        [Rivet_Session] $Session,

        [Parameter(Mandatory, ParameterSetName='Redo')]
        [switch] $Redo,

        # Reverse the given migration(s).
        [Parameter(Mandatory, ParameterSetName='Pop')]
        [Parameter(Mandatory, ParameterSetName='PopByName')]
        [Parameter(Mandatory, ParameterSetName='PopByCount')]
        [Parameter(Mandatory, ParameterSetName='PopAll')]
        [switch] $Pop,

        [Parameter(ParameterSetName='Push')]
        [Parameter(Mandatory, ParameterSetName='PopByName')]
        [string[]] $MigrationName,

        # Reverse the given migration(s).
        [Parameter(Mandatory, ParameterSetName='PopByCount')]
        [UInt32] $Count,

        # Reverse the given migration(s).
        [Parameter(Mandatory, ParameterSetName='PopAll')]
        [switch] $All,

        # Force popping a migration you didn't apply or that is old.
        [Parameter(ParameterSetName='Redo')]
        [Parameter(ParameterSetName='Pop')]
        [Parameter(ParameterSetName='PopByCount')]
        [Parameter(ParameterSetName='PopByName')]
        [Parameter(ParameterSetName='PopAll')]
        [switch] $Force
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    function ConvertTo-RelativeTime
    {
        param(
            # The date time to convert to a relative time string.
            [Parameter(Mandatory)]
            [DateTime] $DateTime
        )

        [TimeSpan]$howLongAgo = (Get-Date) - $DateTime
        $howLongAgoMsg = New-Object 'Text.StringBuilder'
        if( $howLongAgo.Days )
        {
            [void] $howLongAgoMsg.AppendFormat('{0} day', $howLongAgo.Days)
            if( $howLongAgo.Days -ne 1 )
            {
                [void] $howLongAgoMsg.Append('s')
            }
            [void] $howLongAgoMsg.Append(', ')
        }

        if( $howLongAgo.Days -or $howLongAgo.Hours )
        {
            [void] $howLongAgoMsg.AppendFormat('{0} hour', $howLongAgo.Hours)
            if( $howLongAgo.Hours -ne 1 )
            {
                [void] $howLongAgoMsg.Append('s')
            }
            [void] $howLongAgoMsg.Append(', ')
        }

        if( $howLongAgo.Days -or $howLongAgo.Hours -or $howLongAgo.Minutes )
        {
            [void] $howLongAgoMsg.AppendFormat('{0} minute', $howLongAgo.Minutes)
            if( $howLongAgo.Minutes -ne 1 )
            {
                [void] $howLongAgoMsg.Append('s')
            }
            [void] $howLongAgoMsg.Append(', ')
        }

        [void] $howLongAgoMsg.AppendFormat('{0} second', $howLongAgo.Seconds)
        if( $howLongAgo.Minutes -ne 1 )
        {
            [void] $howLongAgoMsg.Append('s')
        }

        [void] $howLongAgoMsg.Append( ' ago' )

        return $howLongAgoMsg.ToString()
    }

    function Get-AppliedMigration
    {
        [CmdletBinding()]
        param(
        )

        $query = "if (object_id('${RivetMigrationsTableFullName}', 'U') is not null) " +
        "select ID, Name, Who, AtUtc from ${RivetMigrationsTableFullName}"
        $appliedMigrations = @{}
        foreach( $migration in (Invoke-Query -Session $Session -Query $query) )
        {
            $appliedMigrations[$migration.ID] = $migration
        }

        return $appliedMigrations
    }

    if ($Redo)
    {
        $updateArgs = [hashtable]::New($PSBoundParameters)
        $updateArgs.Remove('Redo')
        Update-Database -Pop -Count 1 @updateArgs
        Update-Database @updateArgs
        return
    }

    $who = ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME);

    $byName = @{ }
    if ($PSBoundParameters.ContainsKey('MigrationName'))
    {
        $byName['Include'] = $MigrationName
    }

    $popping = ($PSCmdlet.ParameterSetName -like 'Pop*')
    $pushing = -not $popping

    # We have to load all the migrations from files at the same time so that `Get-MigrationFile` can better track if
    # a migration with a specific name exists or not.
    $migrationFilesByDb =
        $Session.Databases |
        Get-MigrationFile @byName -ForExecution -Descending:$popping |
        Group-Object -Property 'DatabaseName'

    try
    {
        foreach ($dbInfo in $Session.Databases)
        {
            Connect-Database -Session $Session -Name $dbInfo.Name

            $appliedMigrations = Get-AppliedMigration

            $numPopped = 0

            $migrationFiles =
                $migrationFilesByDb | Where-Object 'Name' -EQ $dbInfo.Name | Select-Object -ExpandProperty 'Group'

            if (-not $migrationFiles)
            {
                continue
            }


            $conn = $Session.Connection
            foreach ($migrationFile in $migrationFiles)
            {
                if( $PSCmdlet.ParameterSetName -eq 'PopByCount' -and $numPopped -ge $Count )
                {
                    break
                }

                $appliedMigration = $appliedMigrations[$migrationFile.MigrationID]

                if ($pushing)
                {
                    # Don't need to push if migration as already been applied.
                    if ($appliedMigration)
                    {
                        continue
                    }

                    # Only apply baseline migration if non-Rivet migrations haven' been applied to the database.
                    if ($migrationFile.IsBaselineMigration -and `
                        ($appliedMigrations.Values | Where-Object 'ID' -GE $script:firstMigrationId))
                    {
                        continue
                    }
                }

                # Don't need to pop if migration hasn't been applied.
                if ($popping -and (-not $appliedMigration -or $migrationFile.IsRivetMigration))
                {
                    continue
                }

                $youngerThan = ((Get-Date).ToUniversalTime()) - (New-TimeSpan -Minutes 20)
                if ($popping -and ($appliedMigration.Who -ne $who -or $appliedMigration.AtUtc -lt $youngerThan))
                {
                    $howLongAgo = ConvertTo-RelativeTime -DateTime ($appliedMigration.AtUtc.ToLocalTime())
                    $conn = $Session.Connection
                    $migrationName = "$($appliedMigration.ID)_$($appliedMigration.Name)"
                    $confirmQuery = "Are you sure you want to pop migration ${migrationName} from database " +
                                    "$($conn.Database) on $($conn.DataSource) applied by $($appliedMigration.Who) " +
                                    "${howLongAgo}?"
                    $confirmCaption = "Pop Migration ${migrationName}?"
                    if( -not $Force -and -not $PSCmdlet.ShouldContinue( $confirmQuery, $confirmCaption ) )
                    {
                        break
                    }
                }

                # Parse as close to actually running the migration code as possible.
                $migration = $migrationFile | Convert-FileInfoToMigration -Session $Session

                $migration.DataSource = $conn.DataSource

                $trx = $Session.CurrentTransaction = $conn.BeginTransaction()
                $rollback = $true
                try
                {
                    # Rivet's internal migrations should *always* be pushed.
                    if ($popping)
                    {
                        $operations = $migration.PopOperations
                        $action = 'Pop'
                        $sprocName = 'RemoveMigration'
                    }
                    else
                    {
                        $operations = $migration.PushOperations
                        $action = 'Push'
                        $sprocName = 'InsertMigration'
                    }

                    if (-not $operations.Count)
                    {
                        Write-Error ('{0} migration''s {1}-Migration function is empty.' -f $migration.FullName,$action)
                        return
                    }

                    $operations | Invoke-MigrationOperation -Session $Session -Migration $migration

                    $query = "exec [rivet].[${sprocName}] @ID = @ID, @Name = @Name, @Who = @Who, @ComputerName = @ComputerName"
                    $parameters = @{
                        ID = [int64]$migration.ID;
                        Name = $migration.Name;
                        Who = $who;
                        ComputerName = $env:COMPUTERNAME;
                    }
                    Invoke-Query -Session $Session -Query $query -NonQuery -Parameter $parameters  | Out-Null

                    $target = '{0}.{1}' -f $conn.DataSource,$conn.Database
                    $operation = '{0} migration {1} {2}' -f $PSCmdlet.ParameterSetName,$migration.ID,$migration.Name
                    if ($PSCmdlet.ShouldProcess($target, $operation))
                    {
                        $trx.Commit()
                    }
                    else
                    {
                        $trx.Rollback()
                        $rollback = $false
                        break
                    }
                    $rollback = $false
                }
                finally
                {
                    if ($popping)
                    {
                        $numPopped++
                    }

                    if ($rollback)
                    {
                        $trx.Rollback()
                    }

                    $Session.CurrentTransaction = $null
                }

                if ($migration.IsBaselineMigration)
                {
                    $appliedMigrations = Get-AppliedMigration
                }
            }
        }
    }
    finally
    {
        Disconnect-Database -Session $Session
    }
}
