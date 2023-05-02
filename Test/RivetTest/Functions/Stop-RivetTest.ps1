
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

    if( -not (Test-Pester) -and (Test-Path -Path $RTDatabasesRoot -PathType Container) )
    {
        Remove-Item -Path $RTDatabasesRoot -Recurse
    }

    $script:RTTestRoot = $null

    Write-RTTiming -Message ('Stop-RivetTest  END')
}
