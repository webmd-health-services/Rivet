
function Invoke-RivetTestQuery
{
    [CmdletBinding(DefaultParameterSetName='AsReader')]
    param(
        [string]
        $Query,
        
        [Data.SqlClient.SqlConnection]
        $Connection,

        [Switch]
        # Use the master connection, instead of the database connection.
        $Master,
        
        [Parameter(ParameterSetName='AsScalar')]
        [Switch]
        $AsScalar,

        [Parameter()]
        # The timeout to use, in seconds.
        $Timeout,

        [string]
        $DatabaseName
    )
    
    Set-StrictMode -Version Latest

    if( -not $DatabaseName )
    {
        $DatabaseName = $RTDatabaseName
    }

    if( $Master )
    {
        $DatabaseName = 'master'
    }
    
    if( -not $connection -or $connection.State -ne [Data.ConnectionState]::Open )
    {
        $Connection = New-SqlConnection -Database $DatabaseName
        Write-Verbose -Message ('                {0}' -f $Connection.ConnectionString)
    }

    if( -not $PSBoundParameters.ContainsKey('Connection') )
    {
        if( $Connection.Database -ne $DatabaseName )
        {
            $Connection.ChangeDatabase( $DatabaseName )
            Write-Verbose -Message ('                {0}' -f $Connection.ConnectionString)
        }
    }

    $cmdStartedAt = Get-Date
    try
    {
        $cmd = New-Object Data.SqlClient.SqlCommand ($Query,$Connection)
        if( $PSBoundParameters.ContainsKey( 'Timeout' ) )
        {
            $cmd.CommandTimeout = $Timeout
        }

        if( $PSCmdlet.ParameterSetName -eq 'AsScalar' )
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
                        $value = $cmdReader.GetValue($i)
                        if( $cmdReader.IsDBNull($i) )
                        {
                            $value = $null
                        }
                        $row[$name] = $value
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
        $queryLines = $Query -split ([TExt.RegularExpressions.Regex]::Escape([Environment]::NewLine))
        Write-Verbose -Message ('{0,8} (ms)   {1}' -f ([int]((Get-Date) - $cmdStartedAt).TotalMilliseconds),($queryLines | Select-Object -First 1))
        $queryLines | Select-Object -Skip 1 | ForEach-Object {  Write-Verbose -Message ('{0}   {1}' -f (' ' * 13),$_) }
    }
}
