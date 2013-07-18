
function Disconnect-Database
{
    param(
    )
    
    if( $Connection )
    {
        $Connection.Close()
        $Connection.ScriptsPath = $null
    }
}