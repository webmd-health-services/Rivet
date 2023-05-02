
function Connect-RivetSession
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Rivet_Session] $Session
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    # We want the first database to be the default database.
    for($idx = $Session.Databases.Count - 1; $idx -ge 0 ; --$idx)
    {
        Connect-Database -Session $Session -Name $Session.Databases[$idx].Name
    }
}
