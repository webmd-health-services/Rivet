
function Invoke-Query
{
    <#
    .SYNOPSIS
    Executes a SQL query against the database.
    
    .DESCRIPTION
    All migrations eventually come down to this method.  It takes raw SQL and executes it against the database.
    
    .EXAMPLE
    Invoke-Query -Query 'create table pstep.Migrations( )'
    
    Executes the create table syntax above against the database.
    
    .EXAMPLE
    Invoke-Query -Query 'select count(*) from MyTable' -Database MyOtherDatabase
    
    Executes a query against the non-current database.  Returns the rows as objects.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Query,
        
        [Hashtable]
        $Parameter = @{ },
        
        [Parameter(Mandatory=$true,ParameterSetName='ExecuteNonQuery')]
        [Switch]
        $NonQuery,
        
        [Parameter(Mandatory=$true,ParameterSetName='ExecuteScalar')]
        [Switch]
        $Scalar,
        
        [Parameter(Mandatory=$true,ParameterSetName='ExecuteReader')]
        [Switch]
        $Reader,
        
        [UInt32]
        # The time in seconds to wait for the command to execute. The default is 30 seconds.
        $CommandTimeout = 30
    )
    
    $cmd = New-Object Data.SqlClient.SqlCommand ($Query,$Connection)
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
        elseif( $pscmdlet.ParameterSetName -eq 'ExecuteReader' )
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
    }
}
