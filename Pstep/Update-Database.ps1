
function Update-Database
{
    <#
    .SYNOPSIS
    Applies a set of migrations to the database.
    
    .DESCRIPTION
    By default, applies all unapplied migrations to the database.  You can reverse all migrations with the `Down` switch.
    
    .EXAMPLE
    Update-Database -Path C:\Projects\Pstep\Databases\Pstep\Migrations
    
    Applies all un-applied migrations from the `C:\Projects\Pstep\Databases\Pstep\Migrations` directory.
    
    .EXAMPLE
    Update-Database -Path C:\Projects\Pstep\Databases\Pstep\Migrations -Down
    
    Reverses all migrations in the `C:\Projects\Pstep\Databases\Pstep\Migrations` directory
    #>
    [CmdletBinding(DefaultParameterSetName='Push')]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]
        # The path to the migration.
        $Path,
        
        [Parameter(Mandatory=$true,ParameterSetName='Pop')]
        [UInt32]
        # Reverse the given migration(s).
        $Pop
    )
    
    $stopMigrating = $false
    
    $popping = ($pscmdlet.ParameterSetName -eq 'Pop')
    $numPopped = 0
    
    $Path | ForEach-Object {
        if( (Test-Path $_ -PathType Container) )
        {
            Get-ChildItem $_ '*_*.ps1'
        }
        else
        {
            Get-Item $_
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
            if( $numPopped -ge $Pop )
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
            Remove-Item -Path $pushFunctionPath
        }
        
        $popFuntionPath = 'function:Pop-Migration'
        if( (Test-Path -Path $popFuntionPath) )
        {
            Remove-Item -Path $popFuntionPath
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
            $DBScriptRoot = $Connection.ScriptsPath

            if( $Pop )
            {
                if( -not (Test-Path $popFuntionPath) )
                {
                    Write-Error ('Push function for migration {0} not found.' -f $migrationInfo.FullName)
                    return
                }
                
                Write-Host $hostOutput
                Pop-Migration
                Remove-Item -Path $popFuntionPath
                $auditQuery = "delete from {0} where ID={1}" -f $PstepMigrationsTableFullName,$migrationInfo.MigrationID
                Invoke-Query -Query $auditQuery
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
                Remove-Item -Path $pushFunctionPath
                $auditQuery = "insert into {0} (ID,Name,Who,ComputerName) values ({1},'{2}','{3}','{4}')"
                $who = '{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME
                $auditQuery = $auditQuery -f $PstepMigrationsTableFullName,$migrationInfo.MigrationID,$migrationInfo.MigrationName,$who,$env:COMPUTERNAME
                Invoke-Query -Query $auditQuery
            }
            $Connection.Transaction.Commit()
        }
        catch
        {
            $Connection.Transaction.Rollback()
            
            $stopMigrating = $true
            
            # TODO: Create custom exception for migration query errors so that we can report here when unknown things happen.
            if( $_.Exception -isnot [ApplicationException] )
            {
                Write-PstepError -Message ('Migration {0} failed' -f $migrationInfo.FullName) -Exception $_.Exception -CallStack (Get-PSCallStack)
            }            
        }
        finally
        {
            $Connection.Transaction = $null
        }
    }
}
