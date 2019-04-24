
function Clear-TestDatabase
{
    <#
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Name
    )

    Set-StrictMode -Version 'Latest'

    $startedAt = Get-Date

    if( (Test-Path -Path $RTDatabasesRoot -PathType Container) )
    {
        Invoke-RTRivet -Pop -All -Database $Name -ConfigFilePath $RTConfigFilePath
    }

    if( Test-Database -Name $Name )
    {
        Write-Debug -Message ('RTRivetRoot = {0}' -f $RTRivetRoot)
        $expectedCount = Get-ChildItem -Path (Join-Path -Path $RTRivetRoot -ChildPath 'Migrations') -Filter '*.ps1' | Measure-Object | Select-Object -ExpandProperty 'Count'
        $query = 'select * from [{0}].[rivet].[Migrations] order by ID' -f $Name
        [object[]]$migrations = Invoke-RivetTestQuery -Query $query -DatabaseName $Name
        if( $migrations.Count -gt $expectedCount )
        {
            Remove-RivetTestDatabase -Name $Name
            $migrationList = $migrations | Select-Object -Skip $expectedCount | Format-Table -Property 'ID','Name' -AutoSize | Out-String
            Fail ('The following migrations weren''t popped from {0}. Please update your test so that its `Pop-Migration` function correctly reverses the operations performed in its `Push-Migration` function.{1}{2}' -f $Name,([Environment]::NewLine),$migrationList)
        }

        $query = 'select s.name [schema], o.name, o.type_desc from sys.objects o join sys.schemas s on o.schema_id = s.schema_id where s.name != ''rivet'' and o.is_ms_shipped = 0'
        [object[]]$objects = Invoke-RivetTestQuery -Query $query -DatabaseName $Name
        if( $objects )
        {
            Remove-RivetTestDatabase -Name $Name
            $objectList = $objects | Select-Object | Format-Table -Property 'schema','name','type_desc' -AutoSize | Out-String
            Fail ('The following objects weren''t properly removed from {0}. Please ensure each of your migrations has a `Pop-Migration` function that reverses the operations performed in its `Push-Migration` function.{1}{2}' -f $Name,([Environment]::NewLine),$objectList)
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