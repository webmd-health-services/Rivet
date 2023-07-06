
function Stop-RivetTest
{
    [CmdletBinding()]
    param(
        [String[]]$DatabaseName = $RTDatabaseName
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    Write-RTTiming -Message ('Stop-RivetTest  BEGIN')

    $script:testNum += 1

    foreach( $name in $DatabaseName )
    {
        Clear-TestDatabase -Name $name
    }

    $script:RTTestRoot = $null

    Write-RTTiming -Message ('Stop-RivetTest  END')
}
