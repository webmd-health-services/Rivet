
function Get-RivetConfig
{
    <#
    .SYNOPSIS
    Gets the configuration to use when running Rivet.

    .DESCRIPTION
    Rivet will look in the current directory for a `rivet.json` file.  

    .LINK
    about_Rivet_Configuration

    .EXAMPLE
    Get-RivetConfig

    Looks in the current directory for a `rivet.json` file, loads it, and returns an object representing its configuration.

    .EXAMPLE
    Get-RivetConfig -Path F:\etc\rivet

    Demonstrates how to load a custom Rivet configuration file.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        # The path to the Rivet configuration file to load.  Defaults to `rivet.json` in the current directory.
        $Path
    )

    Set-StrictMode -Version Latest

    function Resolve-RivetConfigPath
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
            [string]
            # The path from the rivet config file to resolve.
            $Path
        )
        process
        {
            if( [IO.Path]::IsPathRooted( $Path ) )
            {
                return [IO.Path]::GetFullPath( $Path )
            }

            $Path = Join-Path -Path $configRoot -ChildPath $Path
            return [IO.Path]::GetFullPath( $Path )
        }
    }

    filter Set-ConfigProperty
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)]
            [string]
            # The name of the property to get.
            $Name,

            [Switch]
            # The configuration value is required.
            $Required,

            [Parameter(Mandatory=$true,ParameterSetName='AsInt')]
            [Switch]
            # Set the configuration value as an integer.
            $AsInt,

            [Parameter(Mandatory=$true,ParameterSetName='AsPath')]
            [Switch]
            # Set the configuration value as a path.
            $AsPath,

            [Parameter(Mandatory=$true,ParameterSetName='AsString')]
            [Switch]
            # Set the configuration value as a string.
            $AsString
        )

        if( -not ($rawConfig | Get-Member -Name $Name) )
        {
            if( $Required )
            {
                Write-ValidationError ('setting ''SqlServerName'' is missing.' -f $Name)
                return $false
            }
            return $true
        }

        switch ($PSCmdlet.ParameterSetName )
        {
            'AsInt'
            {
                if( -not ($rawConfig.$Name -is 'int') )
                {
                    Write-ValidationError -Message ('setting ''{0}'' is invalid. It should be a positive integer.' -f $Name)
                    return $false
                }
                $properties.$Name = [int]$rawConfig.$Name
                break
            }
            'AsPath'
            {
                $path = $rawConfig.$Name  | Resolve-RivetConfigPath
                if( -not (Test-Path -Path $path -PathType Container) )
                {
                    Write-ValidationError ('path {0} ''{1}'' not found.' -f $Name,$path)
                    return $false
                }
                $properties.$Name = $path
                break
            }
            'AsString'
            {
                $properties.$Name = $rawConfig.$Name
                break
            }
        }

        return $true
    }

    function Write-ValidationError
    {
        param(
            [Parameter(Mandatory=$true,Position=1)]
            [string]
            # The error message to write.
            $Message
        )
        Write-Error -Message ('Invalid Rivet configuration file ''{0}'': {1} See about_Rivet_Configuration for more information.' -f $Path,$Message)
    }

    if( -not $Path )
    {
        $Path = Get-Location
        $Path = Join-Path -Path $Path -ChildPath 'rivet.json'
    }

    if( -not (Test-Path -Path $Path -PathType Leaf) )
    {
        Write-Error ('Rivet configuration file ''{0}'' not found.' -f $Path)
        return
    }

    $configRoot = Split-Path -Parent -Path $Path

    $properties = @{
                        SqlServerName = 'computername\instancename';
                        ConnectionTimeout = 15;
                        CommandTimeout = 30;
                        Databases = @(
                                        @{
                                            Name = 'One';
                                            ScriptsRoot = (Join-Path -Path $configRoot -ChildPath 'Databases\One');
                                        }
                                     )
                   }

    $rawConfig = ((Get-Content -Path $Path) -join "`n") | ConvertFrom-Json

    $valid = (Set-ConfigProperty -Name SqlServerName -Required -AsString) -and `
                (Set-ConfigProperty -Name DatabasesRoot -Required -AsPath) -and `
                (Set-ConfigProperty -Name ConnectionTimeout -AsInt) -and `
                (Set-ConfigProperty -Name CommandTimeout -AsInt)

    if( $valid )
    {
        return New-Object PsObject -Property $properties
    }
}