
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

    Write-Timing -Message 'Invoke-RivetPlugin  BEGIN' -Indent

    $responders = $plugins |
                        Where-Object {
                            $_.ScriptBlock.Attributes | Where-Object { $_ -is [Rivet.PluginAttribute] -and $_.RespondsTo -eq $Event }
                        }
    try
    {
        if( -not $responders )
        {
            return
        }

        foreach( $plugin in $responders )
        {
            foreach( $parameterName in $Parameter.Keys )
            {
                if( -not $plugin.Parameters.ContainsKey($parameterName) )
                {
                    Write-Error -Message ('The function "{0}" that responds to Rivet''s "{1}" event must have a named "{2}" parameter. Please update this function''s definition.' -f $plugin.Name,$Event,$parameterName) -ErrorAction Stop
                }
            }

            & $plugin.Name @Parameter
            Write-Timing -Message ('                     {0}' -f $plugin.Name)
        }
    }
    finally
    {
        Write-Timing -Message 'Invoke-RivetPlugin  END' -Outdent
    }
}