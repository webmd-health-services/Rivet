
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
    
    Disconnect-Database
    
    $connString = 'Server={0};Database={1};Integrated Security=True;Connection Timeout={2}' -f $SqlServerName,$Database,$ConnectionTimeout
    Set-Variable -Name 'Connection' -Scope 1 -Value (New-Object Data.SqlClient.SqlConnection ($connString))

    $Connection.Open()
    
    $Connection |
        Add-Member -MemberType NoteProperty -Name Transaction -Value $null -PassThru |
        Add-Member -MemberType NoteProperty -Name ScriptsPath -Value $null 
}