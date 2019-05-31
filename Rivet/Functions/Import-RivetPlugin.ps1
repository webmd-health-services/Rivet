
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
    
    Write-Timing -Message 'Import-RivetPlugin  BEGIN' -Indent

    foreach( $pluginPath in $Path )
    {
        Import-Module -Name $pluginPath -Global -Force
        Write-Timing -Message ('                    {0}' -f $pluginPath) -Indent
    }

    $script:plugins = Get-Command -CommandType Function |
                        Where-Object {
                            $_.ScriptBlock.Attributes | 
                                Where-Object { $_ -is [Rivet.PluginAttribute] }
                        }
    Write-Timing -Message ('                    Discovered {0} plugins.' -f ($plugins | Measure-Object).Count)

    Write-Timing -Message 'Import-RivetPlugin  END' -Outdent
}