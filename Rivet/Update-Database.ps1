
function Update-Database
{
    <#
    .SYNOPSIS
    Applies a set of migrations to the database.
    
    .DESCRIPTION
    By default, applies all unapplied migrations to the database.  You can reverse all migrations with the `Down` switch.
    
    .EXAMPLE
    Update-Database -Path C:\Projects\Rivet\Databases\Rivet\Migrations -DBScriptsPath C:\Projects\Rivet\Databases\Rivet
    
    Applies all un-applied migrations from the `C:\Projects\Rivet\Databases\Rivet\Migrations` directory.
    
    .EXAMPLE
    Update-Database -Path C:\Projects\Rivet\Databases\Rivet\Migrations -DBScriptsPath C:\Projects\Rivet\Databases\Rivet -Pop
    
    Reverses all migrations in the `C:\Projects\Rivet\Databases\Rivet\Migrations` directory
    #>
    [CmdletBinding(DefaultParameterSetName='Push', SupportsShouldProcess=$True)]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]
        # The path to the migration.
        $Path,

        [Parameter(Mandatory=$true)]
        [string]
        # The path to the database's scripts directory.
        $DBScriptsPath,
        
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


    Get-MigrationScript -Path $Path |
        Sort-Object -Property 'MigrationID' -Descending:$popping |
        Where-Object { 
            if( -not $PSBoundParameters.ContainsKey('Name') )
            {
                return $true
            }

            $matchesName =  ( $_.MigrationName -like $Name -or $_.MigrationID -like $Name )
            $foundNameMatch = $foundNameMatch -or $matchesName
            return $matchesName
        } |
        Where-Object {

            if( $RivetSchema )
            {
                return $true
            }

            if( $_.MigrationID -lt 1000000000000 )
            {
                Write-Error ('Migration ''{0}'' has an invalid ID. IDs lower than 01000000000000 are reserved for internal use.' -f $_.BaseName)
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
                $migration = Test-Migration -ID $_.MigrationID -PassThru #-ErrorAction Ignore
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
                    $confirmQuery = "Are you sure you want to pop migration {0} from database {1} on {2} applied by {3} {4}?" -f $_.BaseName,$Connection.Database,$Connection.DataSource,$migration.Who,$howLongAgo
                    $confirmCaption = "Pop Migration {2}?" -f $Connection.DataSource,$Connection.Database,$_.BaseName
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
        
            $pushFunctionPath = 'function:Push-Migration'
            if( (Test-Path -Path $pushFunctionPath) )
            {
                Remove-Item -Path $pushFunctionPath -Confirm:$false -WhatIf:$false
            }
        
            $popFuntionPath = 'function:Pop-Migration'
            if( (Test-Path -Path $popFuntionPath) )
            {
                Remove-Item -Path $popFuntionPath -Confirm:$false -WhatIf:$false
            }
        
            . $migrationInfo.FullName
        
        
            $action = '+'
            if( $Pop )
            {
                $action = '-'
            }
            $hostOutput = '[{0}] {1}{2}' -f $migrationInfo.MigrationID,$action,$migrationInfo.MigrationName
        
            try
            {
                $Connection.Transaction = $Connection.BeginTransaction()
                $DBScriptRoot = $DBScriptsPath
                $DBMigrationsRoot = Join-Path -Path $DBScriptsPath -ChildPath Migrations

                $parameters = @{
                                    ID = [int64]$migrationInfo.MigrationID; 
                                    Name = $migrationInfo.MigrationName;
                                    Who = $who;
                                    ComputerName = $env:COMPUTERNAME;
                                }
                if( $Pop )
                {
                    if( -not (Test-Path $popFuntionPath) )
                    {
                        Write-Error ('Push function for migration {0} not found.' -f $migrationInfo.FullName)
                        return
                    }
                
                    Write-Host $hostOutput
                    Pop-Migration
                    Remove-Item -Path $popFuntionPath -Confirm:$false -WhatIf:$false

                    $query = 'exec [rivet].[RemoveMigration] @ID = @ID, @Name = @Name, @Who = @Who, @ComputerName = @ComputerName'
                    Invoke-Query -Query $query -NonQuery -Parameter $parameters  | Out-Null
                }
                else
                {
                    if( -not (Test-Path $pushFunctionPath) )
                    {
                        Write-Error ('Push function for migration {0} not found.' -f $migrationInfo.FullName)
                        return
                    }
                
                    Write-Host $hostOutput
                    Push-Migration
                    Remove-Item -Path $pushFunctionPath -Confirm:$False -WhatIf:$false

                    $query = 'exec [rivet].[InsertMigration] @ID = @ID, @Name = @Name, @Who = @Who, @ComputerName = @ComputerName'
                    Invoke-Query -Query $query -NonQuery -Parameter $parameters | Out-Null
                }

                $target = '{0}.{1}' -f $Connection.DataSource,$Connection.Database
                $operation = '{0} migration {1} {2}' -f $PSCmdlet.ParameterSetName,$migrationInfo.MigrationID,$migrationInfo.MigrationName
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
                    Write-RivetError -Message ('Migration {0} failed' -f $migrationInfo.FullName) -CategoryInfo $_.CategoryInfo.Category -ErrorID $_.FullyQualifiedErrorID -Exception $_.Exception -CallStack ($_.ScriptStackTrace)
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
