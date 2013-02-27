
$server = Get-Content (Join-Path $TestDir Server.txt) -TotalCount 1
$database = 'PstepTest{0}' -f ((get-date).ToString('yyyyMMddHHmmss'))
$masterConnection = $null
$dbConnection = $null
$dbsRoot = New-TempDir
$null = New-Item -Path (Join-Path $dbsRoot "$database\Migrations") -ItemType Directory

function Setup
{
    $connString = 'Server={0};Database=master;Integrated Security=True;' -f $server
    $masterConnection = New-Object Data.SqlClient.SqlConnection ($connString)
    $masterConnection.Open()

    Remove-Database
    New-Database
    Assert-True (_Test-Database)
}

function TearDown
{
    Remove-Database
    Assert-False (_Test-Database)
    $masterConnection.Close()
    if( (Get-Module Pstep) )
    {
        Remove-Module Pstep
    }
}

function Test-ShouldCreatePstepObjectsInDatabase
{
    & (Join-Path $TestDir ..\Pstep\pstep.ps1 -Resolve) -Push -SqlServerName $server -Database $database -Path $dbsRoot
    
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

function New-Database
{
    $query = @'
    if( not exists( select name from sys.databases where Name = '{0}' ) )
    begin
        create database [{0}]
    end
'@ -f $database
    $cmd = New-Object Data.SqlClient.SqlCommand ($query,$masterConnection)
    $cmd.ExecuteNonQuery()
}

function Remove-Database
{
    $query = @'
    if( exists( select name from sys.databases where Name = '{0}' ) )
    begin
        ALTER DATABASE [{0}] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE

        DROP DATABASE [{0}]
    end
'@ -f $database

    $cmd = New-Object Data.SqlClient.SqlCommand ($query,$masterConnection)
    $cmd.ExecuteNonQuery()
    
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