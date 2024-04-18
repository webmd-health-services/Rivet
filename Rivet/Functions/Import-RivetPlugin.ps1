
function Import-RivetPlugin
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Rivet_Session] $Session
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    Write-Timing -Message 'Import-RivetPlugin  BEGIN' -Indent

    $moduleNames = & {
        foreach( $pluginPath in $Session.PluginPaths )
        {
            if( [IO.Path]::GetExtension($pluginPath) -eq '.ps1' )
            {
                Write-Error -Message ('Unable to import Rivet plugin "{0}": invalid plugin file extension. A Rivet plugin must be a PowerShell module. The path to your plugin must be to a directory that is importable by the `Import-Module` command, or to a .psd1 or .psm1 file.' -f $pluginPath) -ErrorAction Stop
                continue
            }

            Write-Timing -Message "  Import  BEGIN  $($pluginPath)"
            Import-Module -Name $pluginPath -Global -Force -PassThru -Verbose:$false |
                Select-Object -ExpandProperty 'Name' |
                Write-Output
            Write-Timing -Message "  Import  END    $($pluginPath)"
        }

        $Session.PluginModules | Write-Output
    }

    $commands = & {
        foreach( $moduleName in $moduleNames )
        {
            Write-Timing -Message "  Get Commands  BEGIN  $($moduleName)"
            if( -not (Get-Module -Name $moduleName) )
            {
                $msg = ("Unable to load plugins from module ""$($moduleName)"": the module is not loaded. Please " +
                        'call "Import-Module" to load this module before running Rivet. If you want Rivet to load the ' +
                        'module for you, use the "PluginPaths" setting and set it to a list of paths to modules ' +
                        'that Rivet should import.')
                Write-Error -Message $msg -ErrorAction Stop
                continue
            }

            Get-Command -Module $moduleName
            Write-Timing -Message "  Get Commands  END    $($moduleName)"
        }

        # Get any global functions that may be plugins.
        Write-Timing -Message ('  Get Functions  BEGIN')
        Get-Command -CommandType Function | Where-Object { -not $_.Module }
        Write-Timing -Message ('  Get Functions  End')
    }

    $Session.Plugins = & {
        foreach( $command in $commands )
        {
            if( -not ($command | Get-Member -Name 'ScriptBlock') )
            {
                continue
            }

            if( $command.ScriptBlock.Attributes | Where-Object { $_ -is [Rivet.PluginAttribute] } )
            {
                $command | Write-Output
            }
        }

        foreach( $command in $commands )
        {
            if( -not ($command | Get-Member -Name 'ImplementingType') )
            {
                continue
            }

            f( $command.ImplementingType.Attributes | Where-Object { $_ -is [Rivet.PluginAttribute] } )
            {
                $command | Write-Output
            }
        }
    }

    Write-Timing -Message ('  Discovered {0} plugins.' -f ($Session.Plugins | Measure-Object).Count)

    Write-Timing -Message 'Import-RivetPlugin  END' -Outdent
}