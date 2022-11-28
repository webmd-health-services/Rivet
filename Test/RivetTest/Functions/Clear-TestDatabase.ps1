
function Clear-TestDatabase
{
    <#
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Name
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $startedAt = Get-Date

    if( $RTDatabasesRoot -and (Test-Path -Path $RTDatabasesRoot -PathType Container) )
    {
        Invoke-RTRivet -Pop -All -Database $Name -ConfigFilePath $RTConfigFilePath
    }

    if( Test-Database -Name $Name )
    {
        $query = "select * from [$($Name)].[rivet].[Migrations] where ID > $($script:firstMigrationId) order by ID"
        [object[]]$migrations = Invoke-RivetTestQuery -Query $query -DatabaseName $Name
        if( ($migrations | Measure-Object).Count )
        {
            Remove-RivetTestDatabase -Name $Name
            $migrationList = $migrations | Format-Table -Property 'ID','Name' -AutoSize | Out-String
            Write-Error -Message ('The following migrations weren''t popped from {0}. Please update your test so that its `Pop-Migration` function correctly reverses the operations performed in its `Push-Migration` function.{1}{2}' -f $Name,([Environment]::NewLine),$migrationList) -ErrorAction Stop
        }

        $query = 'select s.name [schema], o.name, o.type_desc from sys.objects o join sys.schemas s on o.schema_id = s.schema_id where s.name != ''rivet'' and o.is_ms_shipped = 0'
        [object[]]$objects = Invoke-RivetTestQuery -Query $query -DatabaseName $Name
        if( $objects )
        {
            Remove-RivetTestDatabase -Name $Name
            $objectList = $objects | Select-Object | Format-Table -Property 'schema','name','type_desc' -AutoSize | Out-String
            Write-Error -Message ('The following objects weren''t properly removed from {0}. Please ensure each of your migrations has a `Pop-Migration` function that reverses the operations performed in its `Push-Migration` function.{1}{2}' -f $Name,([Environment]::NewLine),$objectList) -ErrorAction Stop
        }

        $query = "select name from sys.schemas where name not in ('dbo','guest','INFORMATION_SCHEMA','sys','db_owner','db_accessadmin','db_backupoperator','db_datareader','db_datawriter','db_ddladmin','db_denydatareader','db_denydatawriter','db_securityadmin','rivet')"
        [object[]]$schemas = Invoke-RivetTestQuery -Query $query -DatabaseName $Name
        if( $schemas )
        {
            Remove-RivetTestDatabase -Name $Name
            $schemaList = $schemas| Select-Object | Format-Table -Property 'name' -AutoSize | Out-String
            Write-Error ('The following schemas weren''t properly removed from {0}. Please ensure each of your migrations has a `Pop-Migration` function that reverses the operations performed in its `Push-Migration` function.{1}{2}' -f $Name,([Environment]::NewLine),$schemaList) -ErrorAction Stop
        }
    }

    Write-Debug -Message ('{0,8} (ms)   Clear-TestDatabase' -f ([int]((Get-Date) - $startedAt).TotalMilliseconds))
}