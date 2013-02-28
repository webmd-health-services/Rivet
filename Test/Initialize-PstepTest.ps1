
$server = Get-Content (Join-Path $TestDir Server.txt) -TotalCount 1
$database = 'PstepTest{0}' -f ((get-date).ToString('yyyyMMddHHmmss'))

$connString = 'Server={0};Database=master;Integrated Security=True;' -f $server
$masterConnection = New-Object Data.SqlClient.SqlConnection ($connString)
$masterConnection.Open()

$dbsRoot = New-TempDir

Copy-Item -Path (Join-Path $TestDir Databases\PstepTest -Resolve) -Destination $dbsRoot -Recurse
Rename-Item -Path (Join-Path $dbsRoot PstepTest -Resolve) -NewName $database

$pstep = Join-Path $TestDir ..\Pstep\pstep.ps1 -Resolve

function Connect-Database
{
    $connString = 'Server={0};Database={1};Integrated Security=True;' -f $server,$database
    $connection = New-Object Data.SqlClient.SqlConnection ($connString)
    $connection.Open()
    return $connection
}

function Disconnect-Database
{
    param(
        [Data.SqlClient.SqlConnection]
        $Connection
    )
    
    $Connection.Close()
}

function New-Database
{
    Remove-Database
    
    $query = @'
    if( not exists( select name from sys.databases where Name = '{0}' ) )
    begin
        create database [{0}]
    end
'@ -f $database
    $cmd = New-Object Data.SqlClient.SqlCommand ($query,$masterConnection)
    $cmd.ExecuteNonQuery()
}

function Invoke-Query
{
    [CmdletBinding(DefaultParameterSetName='AsReader')]
    param(
        [string]
        $Query,
        
        [Data.SqlClient.SqlConnection]
        $Connection,
        
        [Parameter(ParameterSetName='AsScalar')]
        [Switch]
        $AsScalar
    )
    
    try
    {
        $cmd = New-Object Data.SqlClient.SqlCommand ($Query,$Connection)
        if( $pscmdlet.ParameterSetName -eq 'AsScalar' )
        {
            return $cmd.ExecuteScalar()
        }
        else
        {
            $cmdReader = $cmd.ExecuteReader()
            try
            {
                if( -not $cmdReader.HasRows )
                {
                    return
                }
                
                while( $cmdReader.Read() )
                {
                    $row = @{ }
                    for ($i= 0; $i -lt $cmdReader.FieldCount; $i++) 
                    { 
                        $name = $cmdReader.GetName( $i )
                        if( -not $name )
                        {
                            $name = 'Column{0}' -f $i
                        }
                        $row[$name] = $cmdReader.GetValue($i)
                    }
                    New-Object PsObject -Property $row
                }
            }
            finally
            {
                $cmdReader.Close()
            }
        }
        
    }
    finally
    {
        $cmd.Dispose()
    }
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

