
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
        $Timeout
    )
    
    Set-StrictMode -Version Latest

    if( -not $RTDatabaseConnection )
    {
        $script:RTDatabaseConnection = New-SqlConnection -Database $RTDatabaseName
        if( -not $Connection )
        {
            $Connection = $RTDatabaseConnection
        }
    }
    
    if( -not $PSBoundParameters.ContainsKey('Connection') )
    {
        $Connection = $RTDatabaseConnection
        if( $Master )
        {
            if( $Connection.Database -ne 'Master' )
            {
                $Connection.ChangeDatabase( 'Master' )
            }
        }
        elseif( $Connection.Database -ne $RTDatabaseName )
        {
            $Connection.ChangeDatabase( $RTDatabaseName )
        }
    }

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
    }
}
