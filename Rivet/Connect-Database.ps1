
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

    Disconnect-Database

    $query = 'select 1 from sys.databases where name=''{0}''' -f $Database
    $masterConnString = 'Server={0};Database=master;Integrated Security=True;Connection Timeout={1}' -f $SqlServerName,$ConnectionTimeout
    $masterConn = New-Object Data.SqlClient.SqlConnection ($masterConnString)
    $masterConn.Open()

    try
    {
        $cmd = New-Object 'Data.SqlClient.SqlCommand' $query,$masterConn
        if( -not ($cmd.ExecuteScalar()) )
        {
            Write-Verbose ('Creating database {0}.{1}.' -f $SqlServerName,$Database)
            $query = 'create database [{0}]' -f $Database
            $cmd = New-Object 'Data.SqlClient.SqlCommand' $query,$masterConn
            [void]$cmd.ExecuteNonQuery()
        }
    }
    finally
    {
        $masterConn.Close()
    }
    
    $connString = 'Server={0};Database={1};Integrated Security=True;Connection Timeout={2}' -f $SqlServerName,$Database,$ConnectionTimeout
    Set-Variable -Name 'Connection' -Scope 1 -Value (New-Object Data.SqlClient.SqlConnection ($connString)) -Confirm:$False -WhatIf:$false

    $Connection.Open()
    
    $Connection |
        Add-Member -MemberType NoteProperty -Name Transaction -Value $null -PassThru |
        Add-Member -MemberType NoteProperty -Name ScriptsPath -Value $null 
}