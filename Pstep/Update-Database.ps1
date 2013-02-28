
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
        [Switch]
        # Reverse the given migration(s).
        $Pop
    )
    
    if( $pscmdlet.ParameterSetName -eq 'Push' )
    {
        $Pop = $false
    }
    
    Write-Host ('# {0}.{1}' -f $Connection.DataSource,$Connection.Database)
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
    Where-Object { 
        $migrationExists = Test-Migration -ID $_.MigrationID
        if( $Pop )
        {
            $migrationExists
        }
        else
        {
            -not $migrationExists
        }
    } |
    Sort-Object -Property MigrationID -Descending:$Pop |
    ForEach-Object {
        
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
        
        . $_.FullName
        
        
        $action = '+'
        if( $Pop )
        {
            $action = '-'
        }
        $hostOutput = '[{0}] {1}{2}' -f $_.MigrationID,$action,$_.MigrationName
        
        if( $Pop )
        {
            if( -not (Test-Path $popFuntionPath) )
            {
                Write-Error ('Push function for migration {0} not found.' -f $_.FullName)
                return
            }
            
            Write-Host $hostOutput
            Pop-Migration
            Remove-Item -Path $popFuntionPath
            $auditQuery = "delete from {0} where ID={1}" -f $PstepMigrationsTableFullName,$_.MigrationID
            Invoke-Query -Query $auditQuery
        }
        else
        {
            if( -not (Test-Path $pushFunctionPath) )
            {
                Write-Error ('Push function for migration {0} not found.' -f $_.FullName)
                return
            }
            
            Write-Host $hostOutput
            Push-Migration
            Remove-Item -Path $pushFunctionPath
            $auditQuery = "insert into {0} (ID,Name,Who,ComputerName) values ({1},'{2}','{3}','{4}')"
            $who = '{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME
            $auditQuery = $auditQuery -f $PstepMigrationsTableFullName,$_.MigrationID,$_.MigrationName,$who,$env:COMPUTERNAME
            Invoke-Query -Query $auditQuery
        }
    }
}
