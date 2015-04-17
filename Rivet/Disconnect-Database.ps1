
function Disconnect-Database
{
    param(
    )
    
    if( $Connection -and $Connection.State -ne [Data.ConnectionState]::Closed )
    {
        $Connection.Close()
    }
}