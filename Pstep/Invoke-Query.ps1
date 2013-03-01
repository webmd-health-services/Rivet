
filter Invoke-Query
{
    <#
    .SYNOPSIS
    Executes a SQL query against the database.
    
    .DESCRIPTION
    All migrations eventually come down to this method.  It takes raw SQL and executes it against the database.
    
    You can pipe parameter-less queries to this method, too!
    
    .EXAMPLE
    Invoke-Query -Query 'create table pstep.Migrations( )'
    
    Executes the create table syntax above against the database.
    
    .EXAMPLE
    Invoke-Query -Query 'select count(*) from MyTable' -Database MyOtherDatabase
    
    Executes a query against the non-current database.  Returns the rows as objects.
    
    .EXAMPLE
    'select count(*) from sys.tables' | Invoke-Query -AsScalar
    
    Demonstrates how queries can be piped into `Invoke-Query`.  Also shows how a result can be returned as a scalar.
    #>
    [CmdletBinding(DefaultParameterSetName='AsReader')]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Query,
        
        [Hashtable]
        $Parameter = @{ },
        
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
    
    $cmd = New-Object Data.SqlClient.SqlCommand ($Query,$Connection,$Connection.Transaction)
    $cmd.CommandTimeout = $CommandTimeout
    $Parameter.Keys | ForEach-Object {
        $name = $_
        $value = $Parameter[$name]
        
        [void] $cmd.Parameters.AddWithValue( ('@{0}' -f $name), $value )
    }
    
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
    catch
    {
        $errorMsg = 'Query failed: {0}' -f $Query
        Write-PstepError -Message $errorMsg -Exception $_.Exception -CallStack (Get-PSCallStack)
        throw (New-Object ApplicationException 'Migration failed.',$_.Exception)
    }
    finally
    {
        $cmd.Dispose()
    }
}
