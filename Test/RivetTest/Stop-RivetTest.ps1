
function Stop-RivetTest
{
    [CmdletBinding()]
    param(
        [string[]]
        $DatabaseName = $RTDatabaseName
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    
    foreach( $name in $DatabaseName )
    {
        Clear-TestDatabase -Name $name
    }

    if( -not (Test-Pester) -and (Test-Path -Path $RTDatabasesRoot -PathType Container) )
    {
        Remove-Item -Path $RTDatabasesRoot -Recurse
    }

    $script:RTTestRoot = $null
}
