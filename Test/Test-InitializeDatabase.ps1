
. (Join-Path $TestDir Initialize-PstepTest.ps1 -Resolve)

function Setup
{
    New-Database
    Assert-True (_Test-Database)
}

function TearDown
{
    Remove-Database
    Assert-False (_Test-Database)

    if( (Get-Module Pstep) )
    {
        Remove-Module Pstep
    }
}

function Test-ShouldCreatePstepObjectsInDatabase
{
    & $pstep -Push -SqlServerName $server -Database $database -Path $dbsRoot
    
    $connString = 'Server={0};Database={1};Integrated Security=True;' -f $server,$database
    $connection = New-Object Data.SqlClient.SqlConnection ($connString)
    $connection.Open()
    
    try
    {
        Assert-True (_Test-Database)
        
        $query = 'select count(*) from sys.schemas where name = ''pstep'''
        $cmd = New-Object Data.SqlClient.SqlCommand ($query,$connection)
        $schemaCount = $cmd.ExecuteScalar()
        Assert-Equal 1 $schemaCount 'pstep schema not found'
        
        $query = @'
            select count(*) from sys.tables t inner join sys.schemas s on t.schema_id=s.schema_id 
                where t.name = 'Migrations' and s.name = 'pstep'
'@
        $cmd = New-Object Data.SqlClient.SqlCommand ($query,$connection)
        $tableCount = $cmd.ExecuteScalar()
        Assert-Equal 1 $tableCount
    }
    finally
    {
        $connection.Close()
    }
}

function _Test-Database
{
    $query = @'
    select count(*) Count from sys.databases where Name = '{0}'
'@ -f $database

    $cmd = New-Object Data.SqlClient.SqlCommand ($query,$masterConnection)
    $dbCount = $cmd.ExecuteScalar()
    return ($dbCount -eq 1)
}