
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
        [Parameter(Mandatory=$true)]
        [string[]]
        # The path to the migration.
        $Path,

        [Parameter(Mandatory=$true,ParameterSetName='Pop')]
        [Parameter(Mandatory=$true,ParameterSetName='PopByName')]
        [Parameter(Mandatory=$true,ParameterSetName='PopByCount')]
        [Parameter(Mandatory=$true,ParameterSetName='PopAll')]
        [Switch]
        # Reverse the given migration(s).
        $Pop,

        [Parameter(ParameterSetName='Push')]
        [Parameter(Mandatory=$true,ParameterSetName='PopByName')]
        [string]
        $Name,

        [Parameter(Mandatory=$true,ParameterSetName='PopByCount')]
        [UInt32]
        # Reverse the given migration(s).
        $Count,

        [Parameter(Mandatory=$true,ParameterSetName='PopAll')]
        [Switch]
        # Reverse the given migration(s).
        $All,

        [Switch]
        # Running internal Rivet migrations. This is for internal use only. If you use this flag, Rivet will break when you upgrade. You've been warned!
        $RivetSchema,

        [Parameter(ParameterSetName='Pop')]
        [Parameter(ParameterSetName='PopByCount')]
        [Parameter(ParameterSetName='PopByName')]
        [Parameter(ParameterSetName='PopAll')]
        [Switch]
        # Force popping a migration you didn't apply or that is old.
        $Force
    )

    Set-StrictMode -Version 'Latest'

    function ConvertTo-RelativeTime
    {
        param(
            [Parameter(Mandatory=$true)]
            [DateTime]
            # The date time to convert to a relative time string.
            $DateTime
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

    $stopMigrating = $false
    
    $popping = ($PSCmdlet.ParameterSetName -like 'Pop*')
    $numPopped = 0

    $foundNameMatch = $false
    $who = ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME);

    Get-Migration -Path $Path -ErrorAction Stop |
        Sort-Object -Property 'ID' -Descending:$popping |
        Where-Object { 
            if( -not $PSBoundParameters.ContainsKey('Name') )
            {
                return $true
            }

            $matchesName =  ( $_.Name -like $Name -or $_.ID -like $Name )
            $foundNameMatch = $foundNameMatch -or $matchesName
            return $matchesName
        } |
        Where-Object {

            if( $RivetSchema )
            {
                return $true
            }

            if( $_.ID -lt 1000000000000 )
            {
                Write-Error ('Migration ''{0}'' has an invalid ID. IDs lower than 01000000000000 are reserved for internal use.' -f $_.Path)
                $stopMigrating = $true
                return $false
            }
            return $true
        } |
        Where-Object { 
            $migration = $null
            $preErrorCount = $Global:Error.Count
            try
            {
                $migration = Test-Migration -ID $_.ID -PassThru #-ErrorAction Ignore
            }
            catch
            {
                $errorCount = $Global:Error.Count - $preErrorCount
                for( $idx = 0; $idx -lt $errorCount; ++$idx )
                {
                    $Global:Error.RemoveAt(0)
                }
            }

            if( $popping )
            {
                if( $PSCmdlet.ParameterSetName -eq 'PopByCount' -and $numPopped -ge $Count )
                {
                    return $false
                }
                $numPopped++

                $youngerThan = ((Get-Date).ToUniversalTime()) - (New-TimeSpan -Minutes 20)
                if( $migration -and ($migration.Who -ne $who -or $migration.AtUtc -lt $youngerThan) )
                {
                    $howLongAgo = ConvertTo-RelativeTime -DateTime ($migration.AtUtc.ToLocalTime())
                    $confirmQuery = "Are you sure you want to pop migration {0} from database {1} on {2} applied by {3} {4}?" -f $_.FullName,$Connection.Database,$Connection.DataSource,$migration.Who,$howLongAgo
                    $confirmCaption = "Pop Migration {0}?" -f $_.FullName
                    if( -not $Force -and -not $PSCmdlet.ShouldContinue( $confirmQuery, $confirmCaption ) )
                    {
                        return $false
                    }
                }
                $migration
            }
            else
            {
                -not ($migration)
            }
        } |
        ForEach-Object {
        
            if( $stopMigrating )
            {
                return
            }
        
            $migrationInfo = $_
            $migrationInfo.DataSource = $Connection.DataSource

            try
            {
                $Connection.Transaction = $Connection.BeginTransaction()

                if( $Pop )
                {
                    $operations = $migrationInfo.PopOperations
                    $action = 'Pop'
                    $sprocName = 'RemoveMigration'
                }
                else
                {
                    $operations = $migrationInfo.PushOperations
                    $action = 'Push'
                    $sprocName = 'InsertMigration'
                }

                if( -not $operations.Count )
                {
                    Write-Error ('{0} migration''s {1}-Migration function is empty.' -f $migrationInfo.FullName,$action)
                    return
                }

                $operations | Invoke-MigrationOperation

                $query = 'exec [rivet].[{0}] @ID = @ID, @Name = @Name, @Who = @Who, @ComputerName = @ComputerName' -f $sprocName
                $parameters = @{
                                    ID = [int64]$migrationInfo.ID; 
                                    Name = $migrationInfo.Name;
                                    Who = $who;
                                    ComputerName = $env:COMPUTERNAME;
                                }
                Invoke-Query -Query $query -NonQuery -Parameter $parameters  | Out-Null

                $target = '{0}.{1}' -f $Connection.DataSource,$Connection.Database
                $operation = '{0} migration {1} {2}' -f $PSCmdlet.ParameterSetName,$migrationInfo.ID,$migrationInfo.Name
                if ($PSCmdlet.ShouldProcess($target, $operation))
                {
                    $Connection.Transaction.Commit()
                }
                else 
                {
                    $stopMigrating = $true
                    $Connection.Transaction.Rollback()
                }
            }
            catch
            {
                $Connection.Transaction.Rollback()
            
                $stopMigrating = $true
            
                # TODO: Create custom exception for migration query errors so that we can report here when unknown things happen.
                if( $_.Exception -isnot [ApplicationException] )
                {
                    Write-RivetError -Message ('Migration {0} failed' -f $migrationInfo.Path) -CategoryInfo $_.CategoryInfo.Category -ErrorID $_.FullyQualifiedErrorID -Exception $_.Exception -CallStack ($_.ScriptStackTrace)
                }            
            }
            finally
            {
                $Connection.Transaction = $null
            }
        }

    if( $PSBoundParameters.ContainsKey('Name') -and -not $foundNameMatch )
    {
        Write-Error ('Migration ''{0}'' not found.' -f $Name)
    }
}
