
function Get-SqlServerWmiObject
{
    [CmdletBinding()]
    param(
        # The computer name where SQL Server is running.
        [string]
        $ComputerName = '.'
    )

    New-Object Microsoft.SqlServer.Management.Smo.WMI.ManagedComputer $ComputerName
}

function Enable-SqlServerNetworkProtocols
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $InstanceName,
        
        [string]
        # The computer name where SQL Server is running.  Defaults to the local computer.
        $ComputerName = '.',
        
        [Switch]
        # Enable TCP/IP connections.
        $TcpIP,
        
        [Switch]
        # Enable named pipe connections.
        $NamedPipes,
        
        [Switch]
        # Enable VIA connections.
        $Via,
        
        [Switch]
        # Enabled Shared Memory connection.
        $SharedMemory
    )
    
    $enabledProtocols = @( )
    if( $NamedPipes )
    {
        $enabledProtocols += 'Np'
    }
    
    if( $SharedMemory )
    {
        $enabledProtocols += 'Sm'
    }
    
    if( $TcpIp )
    {
        $enabledProtocols += 'Tcp'
    }
    
    if( $Via )
    {
        $enabledProtocols += 'Via'
    }
    
    if( $enabledProtocols.Length -eq 0 )
    {
        Write-Error "No protocols selected to enable.  Please set at least one protocol flag."
        return
    }
    
    $sqlServerWmi = Get-SqlServerWmiObject -ComputerName $ComputerName
    
    $enabledAProtocol = $false
    foreach( $enabledProtocol in $enabledProtocols )
    {
        $protocolUri = $sqlServerWmi.Urn.ToString() + "/ServerInstance[@Name='$InstanceName']/ServerProtocol[@Name='$enabledProtocol']"
        $protocol = $sqlServerWmi.GetSmoObject($protocolUri)
        if( -not $protocol.IsEnabled )
        {
            $protocol.IsEnabled = $true
            $protocol.alter()
            $enabledAProtocol = $true
        }
    }
    
    if( $enabledAProtocol )
    {
        $sqlServerServiceName = "MSSQL`$$InstanceName"
        $service = Get-Service $sqlServerServiceName -ComputerName $ComputerName -ErrorAction SilentlyContinue
        if( $service )
        {
            Restart-Service -InputObject $service -Force
            $maxTries = 10
            $tryNum = 0
            do
            {
                $result = Invoke-SqlCmd -Query 'select 1' -ServerInstance "$ComputerName\$InstanceName" -Database master -ErrorAction SilentlyContinue
                if( -not $result )
                {
                    Write-Verbose "Waiting for SQL Server to become available for queries."
                    Start-Sleep -Milliseconds 100
                }
                else
                {
                    break
                }
                $tryNum += 1
            }
            while( $tryNum -lt $maxTries )
        }
        else
        {
            Write-Warning "Unable to find SQL Server service for $ComputerName\$InstanceName ($SqlServerServiceName).  You'll need to restart SQL Server manually for protocol changes to take affect."
        }
    }

}

function Invoke-SqlClientCommand
{
    <#
    .SYNOPSIS
    Executes a SQL query using the ADO.NET SqlClient API.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The SQL Server to connect to.
        $ServerInstance,
        
        [Parameter(Mandatory=$true)]
        [string]
        # The database to connect to.
        $Database,
        
        [Parameter(Mandatory=$true)]
        [string]
        # The query to execute/invoke/run.
        $Query,
        
        [Collections.Hashtable]
        # Any parameters to use in the query. 
        $Parameter = @{ },
        
        [UInt32]
        # The connection timeout (in seconds).
        $ConnectionTimeout,
        
        [UInt32]
        # The query timeout (in seconds).
        $QueryTimeout,
        
        [Parameter(Mandatory=$true,ParameterSetName='NonQuery')]
        [Switch]
        # Executes a query that doesn't return any results.  Returns the number of rows affected.
        $NonQuery,
        
        [Parameter(Mandatory=$true,ParameterSetName='Scalar')]
        [Switch]
        # Executes a query and returns the first column of the first row in the result set returned by the query.
        $Scalar,
        
        [Parameter(Mandatory=$true,ParameterSetName='Reader')]
        [Switch]
        # Executes a query and returns each row of the result set.
        $Reader
    )
    
    $connectionString = 'Server={0};Database={1};Integrated Security=True;' -f $ServerInstance,$Database
    if( $PSBoundParameters.ContainsKey( 'ConnectionTimeout' ) )
    {
        $connectionString += ('Connection Timeout={0}' -f $ConnectionTimeout)
    }
    
    $connection = New-Object Data.SqlClient.SqlConnection $connectionString
    $cmd = New-Object Data.SqlClient.SqlCommand ($Query,$connection)
    if( $PSBoundParameters.ContainsKey( 'CommandTimeout' ) )
    {
        $cmd.CommandTimeout = $CommandTimeout
    }
    
    $Parameter.Keys | ForEach-Object {
        $name = $_
        $value = $Parameter[$name]
        
        if( $name -like '@*' )
        {
            Write-Error ('Parameter {0} invalid: parameter names should not begin with ''@''.' -f $name)
            return
        }
        
        $cmd.Parameters.AddWithValue( ('@{0}' -f $name), $value )
    }
    
    $connection.Open()
    try
    {
        if( $pscmdlet.ParameterSetName -eq 'NonQuery' )
        {
            $cmd.ExecuteNonQuery()
        }
        elseif( $pscmdlet.ParameterSetName -eq 'Scalar' )
        {
            $cmd.ExecuteScalar()
        }
        elseif( $pscmdlet.ParameterSetName -eq 'Reader' )
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
                        $row[$cmdReader.GetName( $i )] = $cmdReader.GetValue($i)
                    }
                    New-Object PsObject -Property $row
                }
            }
            finally
            {
                $cmdReader.Close()
            }
        }
        else
        {
            Write-Error ('Unknown parameter set {0}.' -f $pscmdlet.ParameterSetName)
        }
    }
    finally
    {
        $cmd.Dispose()
        $connection.Close()
    }
}


function Test-SqlServerInstance
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The SQL Server instance to check.
        $InstanceName,

        # The computer name where SQL Server is running.
        [string]
        $ComputerName = '.'
    )
    
    $sqlServer = Get-SqlServerWmiObject -ComputerName $ComputerName
    $sqlServerInstance = $sqlServer.ServerInstances | Where-Object { $_.Name -eq $InstanceName }
    if( $sqlServerInstance )
    {
        return $true
    }
    else
    {
        return $false
    }

}