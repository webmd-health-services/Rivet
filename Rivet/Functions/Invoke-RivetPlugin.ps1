
function Invoke-RivetPlugin
{
    [Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidAssignmentToAutomaticVariable', '')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Rivet_Session] $Session,

        [Parameter(Mandatory)]
        [Rivet.Events] $Event,

        [hashtable] $Parameter
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    Write-Timing -Message 'Invoke-RivetPlugin  BEGIN' -Indent


    try
    {
        $responders =
            $plugins |
            Where-Object {
                $_.ScriptBlock.Attributes | Where-Object { $_ -is [Rivet.PluginAttribute] -and $_.RespondsTo -eq $Event }
            }

        if( -not $responders )
        {
            return
        }

        foreach( $plugin in $responders )
        {
            $Parameter.Remove('Session')

            # Pass the context to plug-ins.
            if ($plugin.Parameters.ContainsKey('Session'))
            {
                $Parameter['Session'] = $Session
            }

            foreach( $parameterName in $Parameter.Keys )
            {
                if ($parameterName -ne 'Session' -and -not $plugin.Parameters.ContainsKey($parameterName))
                {
                    $msg = "The function ""$($plugin.Name)"" that responds to Rivet's ""${Event}"" event must have " +
                           "a named ""${parameterName}"" parameter. Please update this function''s definition."
                    Write-Error -Message $msg -ErrorAction Stop
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