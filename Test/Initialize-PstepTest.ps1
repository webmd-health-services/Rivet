
$server = Get-Content (Join-Path $TestDir Server.txt) -TotalCount 1

$connString = 'Server={0};Database=master;Integrated Security=True;' -f $server
$masterConnection = New-Object Data.SqlClient.SqlConnection ($connString)
$masterConnection.Open()

$pstepTestDatabase = $null 
$pstepTestTwoDatabase = $null
$dbsRoot = $null
$pstepTestRoot = $null
$pstepTestTwoRoot = $null
$pstepTestMigrationsDir = $null
$pstepTestTwoMigrationsDir = $null

$pstep = Join-Path $TestDir ..\Pstep\pstep.ps1 -Resolve

function Connect-Database
{
    param(
        $Name = 'PstepTest'
    )
    $dbName = Get-Variable -Name ('{0}Database' -f $Name) -ValueOnly
    $connString = 'Server={0};Database={1};Integrated Security=True;' -f $server,$dbName
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
    param(
        $Name = 'PstepTest'
    )
    
    Remove-Database -Name $Name
    
    if( -not $dbsRoot -or -not (Test-Path -Path $dbsRoot -PathType Container) )
    {
        Set-Variable -Name 'dbsRoot' -Value (New-TempDir) -Scope 1
    }
    
    $dbName = '{0}{1}' -f $Name,(get-date).ToString('yyyyMMddHHmmss')
    Set-Variable -Name ('{0}Database' -f $Name) -Value $dbName -Scope 1
    $dbRoot = Join-Path $dbsRoot $dbName
    Set-Variable -Name ('{0}Root' -f $Name) -Value $dbRoot -Scope 1
    Set-Variable -Name ('{0}MigrationsDir' -f $Name) -Value (Join-Path $dbRoot "Migrations") -Scope 1

    Copy-Item -Path (Join-Path $TestDir Databases\$Name -Resolve) -Destination $dbsRoot -Recurse
    Rename-Item -Path (Join-Path $dbsRoot $Name -Resolve) -NewName $dbName
    
    $query = @'
    if( not exists( select name from sys.databases where Name = '{0}' ) )
    begin
        create database [{0}]
    end
'@ -f $dbName
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
    param(
        $Connection = $connection
    )
    
    $query = 'select count(*) from pstep.Migrations'
    return Invoke-Query -Query $query -Connection $connection -AsScalar
}

function Remove-Database
{
    param(
        $Name = 'PstepTest'
    )
    
    $dbName = Get-Variable -Name ('{0}Database' -f $Name) -ValueOnly
    if( $dbName )
    {
        $query = @'
        if( exists( select name from sys.databases where Name = '{0}' ) )
        begin
            ALTER DATABASE [{0}] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE

            DROP DATABASE [{0}]
        end
'@ -f $dbName

        Invoke-Query -Query $query -Connection $masterConnection
    }
    
    $dbRoot = Get-Variable -Name ('{0}Root' -f $Name) -ValueOnly
    if( $dbRoot -and (Test-Path -Path $dbRoot -PathType Container) )
    {
        Remove-Item -Path $dbRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    if( $dbsRoot -and (Test-Path -Path $dbsRoot -PathType Container) -and -not (Get-ChildItem -Path $dbsRoot) )
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

