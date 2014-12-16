
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

    if( -not $Connection -or $Connection.DataSource -ne $SqlServerName -or $Connection.State -eq [Data.ConnectionState]::Closed)
    {
        Disconnect-Database

        $connString = 'Server={0};Database=master;Integrated Security=True;Connection Timeout={1}' -f $SqlServerName,$ConnectionTimeout
        Set-Variable -Name 'Connection' -Scope 1 -Value (New-Object 'Data.SqlClient.SqlConnection' ($connString)) -Confirm:$False -WhatIf:$false
        $Connection.Open()
    }

    if( $Connection.Database -ne 'master' )
    {
        $Connection.ChangeDatabase( 'master' )
    }

    $query = 'select 1 from sys.databases where name=''{0}''' -f $Database
    $cmd = New-Object 'Data.SqlClient.SqlCommand' $query,$Connection
    if( -not ($cmd.ExecuteScalar()) )
    {
        Write-Verbose ('Creating database {0}.{1}.' -f $SqlServerName,$Database)
        $query = 'create database [{0}]' -f $Database
        $cmd = New-Object 'Data.SqlClient.SqlCommand' $query,$Connection
        [void]$cmd.ExecuteNonQuery()
    }

    $Connection.ChangeDatabase( $Database )
    
    if( -not ($Connection | Get-Member -Name 'Transaction' ) )
    {
        $Connection |
            Add-Member -MemberType NoteProperty -Name 'Transaction' -Value $null
    }

    if( -not ($Connection | Get-Member -Name 'ScriptsPath') )
    {
        $Connection |
            Add-Member -MemberType NoteProperty -Name 'ScriptsPath' -Value $null 
    }
}