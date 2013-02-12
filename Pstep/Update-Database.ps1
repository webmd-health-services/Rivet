
function Invoke-Migration
{
    param(
        [Parameter(Mandatory=$true)]
        [string[]]
        # The path to the migration.
        $Path,
        
        [Switch]
        # Reverse the given migrations.
        $Down
    )
    
    Write-Host ('# {0}.{1}' -f $SqlServerName,$Database)
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
        if( $Down )
        {
            $migrationExists
        }
        else
        {
            -not $migrationExists
        }
    } |
    Sort-Object -Property MigrationID -Descending:$Down |
    ForEach-Object {
        
        $pushFunctionPath = 'function:Push'
        if( (Test-Path -Path $pushFunctionPath) )
        {
            Remove-Item -Path $pushFunctionPath
        }
        
        $popFuntionPath = 'function:Pop'
        if( (Test-Path -Path $popFuntionPath) )
        {
            Remove-Item -Path $popFuntionPath
        }
        
        . $_.FullName
        
        
        $action = '+'
        if( $Down )
        {
            $action = '-'
        }
        $hostOutput = '[{0}] {1}{2}' -f $_.MigrationID,$action,$_.MigrationName
        
        if( $Down )
        {
            if( -not (Test-Path $popFuntionPath) )
            {
                Write-Error ('Push function for migration {0} not found.' -f $_.FullName)
                return
            }
            
            Write-Host $hostOutput
            Pop
            Remove-Item -Path $popFuntionPath
            $auditQuery = "delete from migrations.Migrations where ID={0}" -f $_.MigrationID
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
            Push
            Remove-Item -Path $pushFunctionPath
            $auditQuery = "insert into migrations.Migrations (ID,Name,Who,ComputerName) values ({0},'{1}','{2}','{3}')"
            $auditQuery = $auditQuery -f $_.MigrationID,$_.MigrationName,('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME),$env:COMPUTERNAME
            Invoke-Query -Query $auditQuery
        }
    }
}
