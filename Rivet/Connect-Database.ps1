
function Connect-Database
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The SQL Server instance to connect to.
        $SqlServerName,
        
        [Parameter(Mandatory=$true)]
        [string]
        # The database to connect to.
        $Database,
        
        [UInt32]
        # The time (in seconds) to wait for a connection to open. The default is 10 seconds.
        $ConnectionTimeout = 10
    )
    
    Set-StrictMode -Version 'Latest'

    $startedAt = Get-Date

    if( -not $Connection -or $Connection.DataSource -ne $SqlServerName -or $Connection.State -eq [Data.ConnectionState]::Closed)
    {
        Disconnect-Database

        $connString = 'Server={0};Database=master;Integrated Security=True;Connection Timeout={1}' -f $SqlServerName,$ConnectionTimeout
        Set-Variable -Name 'Connection' -Scope 1 -Value (New-Object 'Data.SqlClient.SqlConnection' ($connString)) -Confirm:$False -WhatIf:$false
        try
        {
            $Connection.Open()
        }
        catch
        {
            $ex = $_.Exception
            while( $ex.InnerException )
            {
                $ex = $ex.InnerException
            }

            Write-Error ('Failed to connect to SQL Server ''{0}'' (connection string: {1}). Does this database server exist? ({2})' -f $SqlServerName,$connString,$ex.Message)
            return $false
        }
    }

    if( -not ($Connection | Get-Member -Name 'Transaction' ) )
    {
        $Connection |
            Add-Member -MemberType NoteProperty -Name 'Transaction' -Value $null
    }

    if( $Connection.Database -ne 'master' )
    {
        $Connection.ChangeDatabase( 'master' )
    }

    $query = 'select 1 from sys.databases where name=''{0}''' -f $Database
    $dbExists = Invoke-Query -Query $query -AsScalar
    if( -not $dbExists )
    {
        Write-Verbose ('Creating database {0}.{1}.' -f $SqlServerName,$Database)
        $query = 'create database [{0}]' -f $Database
        Invoke-Query -Query $query -NonQuery
    }

    $Connection.ChangeDatabase( $Database )

    Write-Verbose -Message ('{0,8} (ms)   Connect-Database' -f ([int]((Get-Date) - $startedAt).TotalMilliseconds))
    return $true
}