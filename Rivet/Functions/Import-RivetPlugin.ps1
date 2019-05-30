
function Import-RivetPlugin
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]]
        $Path
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    
    foreach( $pluginPath in $Path )
    {
        Import-Module -Name $pluginPath -Global -Force
    }
}