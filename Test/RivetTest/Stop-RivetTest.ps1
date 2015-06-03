
function Stop-RivetTest
{

    Set-StrictMode -Version 'Latest'

    Invoke-RTRivet -Pop -All -Database $RTDatabaseName -ConfigFilePath $RTConfigFilePath

    if( Test-Database -Name $RTDatabaseName )
    {
        $expectedCount = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath '..\..\Rivet\Migrations') -Filter '*.ps1' | Measure-Object | Select-Object -ExpandProperty 'Count'
        $query = 'select * from [{0}].[rivet].[Migrations] order by ID' -f $RTDatabaseName
        [object[]]$migrations = Invoke-RivetTestQuery -Query $query
        if( $migrations.Count -gt $expectedCount )
        {
            Remove-RivetTestDatabase
            $migrationList = $migrations | Select-Object -Skip $expectedCount | Format-Table -Property 'ID','Name' -AutoSize | Out-String
            Fail ('The following migrations weren''t popped. Please update your test so that its `Pop-Migration` function correctly reverses the operations performed in its `Push-Migration` function.{0}{1}' -f ([Environment]::NewLine),$migrationList)
        }
        else
        {
            $query = 'select s.name [schema], o.name, o.type_desc from sys.objects o join sys.schemas s on o.schema_id = s.schema_id where s.name != ''rivet'' and o.is_ms_shipped = 0'
            [object[]]$objects = Invoke-RivetTestQuery -Query $query
            if( $objects )
            {
                Remove-RivetTestDatabase
                $objectList = $objects | Select-Object | Format-Table -Property 'schema','name','type_desc' -AutoSize | Out-String
                Fail ('The following objects weren''t properly removed. Please ensure each of your migrations has a `Pop-Migration` function that reverses the operations performed in its `Push-Migration` function.{0}{1}' -f ([Environment]::NewLine),$objectList)
            }
        }
    }

    Remove-Item -Path $RTDatabasesRoot -Recurse
}
