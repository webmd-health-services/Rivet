
function Connect-RivetSession
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Rivet_Session] $Session,

        [String] $Database
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $databasesToConnect = & {
        if( $Database )
        {
            $Database | Write-Output
            return
        }
    
        # If no Database specified, we want the first database to be the default database.
        for($idx = $Session.Databases.Count - 1; $idx -ge 0 ; --$idx)
        {
            $Session.Databases[$idx].Name | Write-Output
        }
    }
    
    foreach ($db in $databasesToConnect)
    {
        Connect-Database -Session $Session -Name $db | Out-Null
    }
}
