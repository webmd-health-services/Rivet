
function Disconnect-Database
{
    param(
        [Parameter(Mandatory)]
        [Rivet_Session] $Session
    )

    $conn = $Session.Connection

    if ($conn -and $conn.State -ne [Data.ConnectionState]::Closed)
    {
        $conn.Close()
    }
}