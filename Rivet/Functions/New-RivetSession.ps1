
function New-RivetSession
{
    <#
    .SYNOPSIS
    Creates a Rivet session object.

    .DESCRIPTION
    The `New-RivetSession` function creates a Rivet session. By default, the function will use the configuration from
    the `rivet.json` in the current directory. To use a custom `rivet.json` file, pass the path to the `rivet.json` file
    to use to the `ConfigurationPath` parameter. To create a session to only a specific set of databases, pass their
    names to the `Database` parameter. The default is to create a session to operate against all databases. To use
    environment-specific settings from the rivet.json file, pass the environment name to the `Environment` parameter.

    .EXAMPLE
    New-RivetSession -ConfigurationPath '.\rivet.json'

    Demonstrates how to create a Rivet session by passing the path to a `rivet.json` file to the `ConfigurationPath`
    parameter.

    .EXAMPLE
    New-RivetSession -ConfigurationPath '.\rivet.json' -Database @('UseThisOne', 'AndThisOne')

    Demonstrates how to create a session objerct that only operates on a specific database. In this example, Rivet will
    only operate on the `UseThisOne` and `AndThisOne` databases.

    .EXAMPLE
    New-RivetSession -ConfigurationPath '.\rivet.json' -Environment 'Test'

    Demonstrates how to use a specific environment when creating the session object. In this example, the session will
    be to the Test environment.
    #>
    [CmdletBinding()]
    [OutputType([Rivet_Session])]
    param(
        # The path to the `rivet.json` file. Defaults to a `rivet.json` file in the current directory.
        [String] $ConfigurationPath,

        # The path to the specific database or databases to use. Only use this if you have multiple databases and want
        # to only operate on a subset of them.
        [String[]] $Database,

        # The name of the environment in the `rivet.json` whose configuration you want to use. Default behavior is to
        # not use any environment-specific settings and use the default settings from the `rivet.json` file.
        [String] $Environment
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    [Rivet.Configuration.Configuration]$settings =
        Get-RivetConfig -Database $Database -Path $ConfigurationPath -Environment $Environment
    if (-not $settings)
    {
        return
    }

    return [Rivet_Session]::New($settings)
}
