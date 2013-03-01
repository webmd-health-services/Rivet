
$server = Get-Content (Join-Path $TestDir Server.txt) -TotalCount 1

$connString = 'Server={0};Database=master;Integrated Security=True;' -f $server
$masterConnection = New-Object Data.SqlClient.SqlConnection ($connString)
$masterConnection.Open()

$database = $null 
$dbsRoot = $null
$migrationsDir = $null

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
    
    Set-Variable -Name 'dbsRoot' -Value (New-TempDir) -Scope 1
    Set-Variable -Name 'database' -Value ('PstepTest{0}' -f ((get-date).ToString('yyyyMMddHHmmss'))) -Scope 1
    Set-Variable -Name 'migrationsDir' -Value (Join-Path $dbsRoot "$database\Migrations") -Scope 1

    Copy-Item -Path (Join-Path $TestDir Databases\PstepTest -Resolve) -Destination $dbsRoot -Recurse
    Rename-Item -Path (Join-Path $dbsRoot PstepTest -Resolve) -NewName $database
    
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

function Measure-Migration
{
    $query = 'select count(*) from pstep.Migrations'
    return Invoke-Query -Query $query -Connection $connection -AsScalar
}

function Remove-Database
{
    if( $database )
    {
        $query = @'
        if( exists( select name from sys.databases where Name = '{0}' ) )
        begin
            ALTER DATABASE [{0}] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE

            DROP DATABASE [{0}]
        end
'@ -f $database

        Invoke-Query -Query $query -Connection $masterConnection
    }
        
    if( $dbsRoot -and (Test-Path -Path $dbsRoot -PathType Container) )
    {
        Remove-Item -Path $dbsRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function _Test-DBObject
{
    param(
        [Parameter(Mandatory=$true,ParameterSetName='U')]
        [Switch]
        $Table,
        
        [Parameter(Mandatory=$true,ParameterSetName='P')]
        [Switch]
        $StoredProcedure,
        
        [Parameter(Mandatory=$true,ParameterSetName='FN')]
        [Switch]
        $ScalarFunction,
        
        [Parameter(Mandatory=$true,ParameterSetName='V')]
        [Switch]
        $View,
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        $Name
    )
    
    
    $query = "select count(*) from sys.objects where type = '{0}' and name = '{1}'" -f $pscmdlet.ParameterSetName,$Name
    $objectCount = Invoke-Query -Query $query -Connection $connection -AsScalar
    return ($objectCount -eq 1)
}

function _Test-Table
{
    param(
        $Name
    )
    return _Test-DBObject -Table -Name $Name
}

