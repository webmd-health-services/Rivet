
function Import-RivetPlugin
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [String[]]$Path
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    
    # $DebugPreference = 'Continue'

    Write-Timing -Message 'Import-RivetPlugin  BEGIN' -Indent

    $commands = & {
        foreach( $pluginPath in $Path )
        {
            if( [IO.Path]::GetExtension($pluginPath) -eq '.ps1' )
            {
                Write-Error -Message ('Unable to import Rivet plugin "{0}": invalid plugin file extension. A Rivet plugin must be a PowerShell module. The path to your plugin must be to a directory that is importable by the `Import-Module` command, or to a .psd1 or .psm1 file.' -f $pluginPath) -ErrorAction $ErrorActionPreference
                continue
            }

            Write-Timing -Message ('  Import {0}  BEGIN' -f $pluginPath)
            $module = Import-Module -Name $pluginPath -Global -Force -PassThru
            Write-Timing -Message ('  Import {0}  END' -f $pluginPath)

            Write-Timing -Message ('  Get Commands  BEGIN')
            Get-Command -Module $module.Name
            Write-Timing -Message ('  Get Commands  END')
        }

        # Get any global functions that may be plugins.
        Write-Timing -Message ('  Get Functions  BEGIN')
        Get-Command -CommandType Function | Where-Object { -not $_.Module }
        Write-Timing -Message ('  Get Functions  End')
    }
 
    $script:plugins = & {
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

    Write-Timing -Message ('  Discovered {0} plugins.' -f ($plugins | Measure-Object).Count)

    Write-Timing -Message 'Import-RivetPlugin  END' -Outdent
}