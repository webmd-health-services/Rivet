
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
        [UInt32]
        # Reverse the given migration(s).
        $Pop,

        [Parameter(ParameterSetName='PopAll')]
        [Switch]
        # Reverse the given migration(s).
        $Force
    )
    
    $stopMigrating = $false
    
    $popping = ($pscmdlet.ParameterSetName -eq 'Pop' -or $pscmdlet.ParameterSetName -eq 'PopAll')
    $numPopped = 0

    $Path | ForEach-Object {
        if( (Test-Path $_ -PathType Container) )
        {
            Get-ChildItem $_ '*_*.ps1'
        }
        elseif( (Test-Path $_ -PathType Leaf) )
        {
            Get-Item $_
        }
        else
        {
            Write-Error ('Migration path ''{0}'' not found.' -f $_)
        }
        
    } | 
    ForEach-Object {
        if( $_.BaseName -notmatch '^(\d{14})_(.+)' )
        {
            Write-Error ('Migration {0} has invalid name.  Must be of the form `YYYYmmddhhMMss_MigrationName.ps1' -f $_.FullName)
            return
        }
        
        $id = [UInt64]$matches[1]
        $name = $matches[2]
        
        $_ | 
            Add-Member -MemberType NoteProperty -Name 'MigrationID' -Value $id -PassThru |
            Add-Member -MemberType NoteProperty -Name 'MigrationName' -Value $name -PassThru
    } |
    Sort-Object -Property MigrationID -Descending:$popping |
    Where-Object { 
        if( $popping )
        {
            if( -not $Force -and $numPopped -ge $Pop )
            {
                return $false
            }
            $numPopped++
            Test-Migration -ID $_.MigrationID
        }
        else
        {
            -not (Test-Migration -ID $_.MigrationID)
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
            Remove-Item -Path $pushFunctionPath -Confirm:$false
        }
        
        $popFuntionPath = 'function:Pop-Migration'
        if( (Test-Path -Path $popFuntionPath) )
        {
            Remove-Item -Path $popFuntionPath -Confirm:$false
        }
        
        . $migrationInfo.FullName
        
        
        $action = '+'
        if( $Pop -or $Force)
        {
            $action = '-'
        }
        $hostOutput = '[{0}] {1}{2}' -f $migrationInfo.MigrationID,$action,$migrationInfo.MigrationName
        
        try
        {
            $Connection.Transaction = $Connection.BeginTransaction()
            $DBScriptRoot = $DBScriptsPath
            $DBMigrationsRoot = Join-Path -Path $DBScriptsPath -ChildPath Migrations

            if( $Pop -or $Force )
            {
                if( -not (Test-Path $popFuntionPath) )
                {
                    Write-Error ('Push function for migration {0} not found.' -f $migrationInfo.FullName)
                    return
                }
                
                Write-Host $hostOutput
                Pop-Migration
                Remove-Item -Path $popFuntionPath -Confirm:$false

                Remove-Row -SchemaName $RivetSchemaName $RivetMigrationsTableName -Quiet -Where ('ID = {0}' -f $migrationInfo.MigrationID)
                $who = '{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME
                Add-Row -SchemaName $RivetSchemaName $RivetActivityTableName -Quiet -Column @{
                                                                            Operation = 'Pop';
                                                                            MigrationID = $migrationInfo.MigrationID;
                                                                            Name = $migrationInfo.MigrationName;
                                                                            Who = $who;
                                                                            ComputerName = $env:COMPUTERNAME;
                                                                          }

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
                Remove-Item -Path $pushFunctionPath -Confirm:$False

                $who = '{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME

                Add-Row -SchemaName $RivetSchemaName $RivetMigrationsTableName -Quiet -Column @{
                                                                                ID = $migrationInfo.MigrationID;
                                                                                Name = $migrationInfo.MigrationName;
                                                                                Who = $who;
                                                                                ComputerName = $env:COMPUTERNAME;
                                                                            }

                Add-Row -SchemaName $RivetSchemaName $RivetActivityTableName -Quiet -Column @{
                                                                                Operation = 'Push';
                                                                                MigrationID = $migrationInfo.MigrationID;
                                                                                Name = $migrationInfo.MigrationName;
                                                                                Who = $who;
                                                                                ComputerName = $env:COMPUTERNAME;
                                                                          }

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
}
