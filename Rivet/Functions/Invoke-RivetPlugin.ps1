
function Invoke-RivetPlugin
{
    param(
        [Parameter(Mandatory)]
        [Rivet.Events]
        $Event,

        [hashtable]
        $Parameter
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $plugins = Get-Command -CommandType Function |
                    Where-Object {
                        $_.ScriptBlock.Attributes | 
                            Where-Object { $_ -is [Rivet.PluginAttribute] -and $_.RespondsTo -eq $Event }
                    }

    foreach( $plugin in $plugins )
    {
        foreach( $parameterName in $Parameter.Keys )
        {
            if( -not $plugin.Parameters.ContainsKey($parameterName) )
            {
                Write-Error -Message ('The function "{0}" that responds to Rivet''s "{1}" event must have a named "{2}" parameter. Please update this function''s definition.' -f $plugin.Name,$Event,$parameterName) -ErrorAction Stop
            }
        }

        & $plugin.Name @Parameter
    }
}