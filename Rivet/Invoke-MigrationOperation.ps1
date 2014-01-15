
function Invoke-MigrationOperation
{
    <#
    .SYNOPSIS
    Runs the SQL created by a `Rivet.Migration` object.

    .DESCRIPTION
    All Rivet migrations are described by instances of `Rivet.Migration` objects.  These objects eventually make their way here, at which point they are converted to SQL, and executed.

    .EXAMPLE
    Invoke-Migration -Operation $operation

    This example demonstrates how to call `Invoke-Migration` with a migration object.
    #>
    [CmdletBinding(DefaultParameterSetName='AsReader')]
    param(
        [Alias('Migration')]
        [Parameter(Mandatory=$true)]
        [Rivet.Operations.Operation]
        # The migration object to invoke.
        $Operation,
        
        [Parameter(Mandatory=$true,ParameterSetName='ExecuteScalar')]
        [Switch]
        $AsScalar,
        
        [Parameter(Mandatory=$true,ParameterSetName='ExecuteNonQuery')]
        [Switch]
        $NonQuery,
        
        [UInt32]
        # The time in seconds to wait for the command to execute. The default is 30 seconds.
        $CommandTimeout = 30
    )

    $query = $Operation.ToQuery()

    $cmd = New-Object Data.SqlClient.SqlCommand ($query,$Connection,$Connection.Transaction)
    $cmd.CommandTimeout = $CommandTimeout

    try
    {
        if( $pscmdlet.ParameterSetName -eq 'ExecuteNonQuery' )
        {
            $cmd.ExecuteNonQuery()
        }
        elseif( $pscmdlet.ParameterSetName -eq 'ExecuteScalar' )
        {
            $cmd.ExecuteScalar()
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
                Write-Verbose $query
                $cmdReader.Close()
            }
        }
    }
    catch
    {
        $errorMsg = 'Query failed: {0}' -f $query
        Write-RivetError -Message ('Migration {0} failed' -f $migrationInfo.FullName) -CategoryInfo $_.CategoryInfo.Category -ErrorID $_.FullyQualifiedErrorID -Exception $_.Exception -CallStack ($_.ScriptStackTrace) -Query $errorMsg
        throw (New-Object ApplicationException 'Migration failed.',$_.Exception)
    }
    finally
    {
        $cmd.Dispose()
    }

}
