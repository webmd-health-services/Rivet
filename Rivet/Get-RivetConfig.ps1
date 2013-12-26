
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
        [string[]]
        # The list of specific database names being operated on.
        $Database,

        [Parameter()]
        # The name of the environment whose settings to return.  If not provided, uses the default settings.
        $Environment,

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

            [Parameter(Mandatory=$true,ParameterSetName='AsList')]
            [Switch]
            # Set the configuration value as a list of strings.
            $AsList,

            [Parameter(Mandatory=$true,ParameterSetName='AsPath')]
            [Switch]
            # Set the configuration value as a path.
            $AsPath,

            [Parameter(Mandatory=$true,ParameterSetName='AsString')]
            [Switch]
            # Set the configuration value as a string.
            $AsString
        )
        
        $value = $null

        if( $rawConfig | Get-Member -Name $Name )
        {
            $value = $rawConfig.$Name
        }

        $env = Get-Environment
        if( $env -and ($env | Get-Member -Name $Name))
        {
            $value = $env.$Name
        }

        if( -not $value )
        {
            if( $Required )
            {
                Write-ValidationError ('setting ''{0}'' is missing.' -f $Name)
                return $false
            }
            return $true
        }

        switch ($PSCmdlet.ParameterSetName )
        {
            'AsInt'
            {
                if( -not ($value -is 'int') )
                {
                    Write-ValidationError -Message ('setting ''{0}'' is invalid. It should be a positive integer.' -f $Name)
                    return $false
                }
                $properties.$Name = $value
                break
            }
            'AsList'
            {
                $properties.$Name = [Object[]]$value
                break
            }
            'AsPath'
            {
                $path = $value  | Resolve-RivetConfigPath
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
                $properties.$Name = $value
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
        $envMsg = ''
        if( $Environment )
        {
            $envMsg = 'environment ''{0}'': ' -f $Environment
        }
        Write-Error -Message ('Invalid Rivet configuration file ''{0}'': {1}{2} See about_Rivet_Configuration for more information.' -f $Path,$envMsg,$Message)
    }


    function Get-Environment
    {
        if( $Environment )
        {
            if( ($rawConfig | Get-Member -Name 'Environments') -and 
                ($rawConfig.Environments | Get-Member -Name $Environment) )
            {
                $rawConfig.Environments.$Environment
            }
        }
    }

    ## If there is no $Path defined set $Path to current directory
    if( -not $Path )
    {
        $Path = Get-Location | Select-Object -ExpandProperty 'ProviderPath'
        $Path = Join-Path -Path $Path -ChildPath 'rivet.json'
    }

    if( -not [IO.Path]::IsPathRooted( $Path ) )
    {
        $Path = Join-Path -Path (Get-Location) -ChildPath $Path
    }

    $Path = [IO.Path]::GetFullPath( $Path )

    ## Check for existence of rivet.json
    if( -not (Test-Path -Path $Path -PathType Leaf) )
    {
        Write-Error ('Rivet configuration file ''{0}'' not found.' -f $Path)
        return
    }

    $configRoot = Split-Path -Parent -Path $Path

    # Defaults
    $properties = @{
                        ConnectionTimeout = 15;
                        CommandTimeout = 30;
                        Databases = @();
                        PluginsRoot = @();
                        IgnoreDatabases = @();
                   }

    $rawConfig = ((Get-Content -Path $Path) -join "`n") | ConvertFrom-Json

    $valid = (Set-ConfigProperty -Name SqlServerName -Required -AsString) -and `
                (Set-ConfigProperty -Name DatabasesRoot -Required -AsPath) -and `
                (Set-ConfigProperty -Name PluginsRoot -AsPath) -and `
                (Set-ConfigProperty -Name ConnectionTimeout -AsInt) -and `
                (Set-ConfigProperty -Name CommandTimeout -AsInt) -and `
                (Set-ConfigProperty -Name IgnoreDatabases -AsList)

    if( $valid )
    {
        if( $Environment -and -not (Get-Environment) )
        {
            Write-Error ('Environment ''{0}'' not found in ''{1}''.' -f $Environment,$Path)
            return
        }

        $properties.Databases = Invoke-Command {

                                    # Get user-specified databases first
                                    if( $Database )
                                    {
                                        $Database | 
                                            Add-Member -MemberType ScriptProperty -Name Name -Value { $this } -PassThru |
                                            Add-Member -MemberType ScriptProperty -Name FullName -Value { Join-Path -Path $properties.DatabasesRoot -ChildPath $this.Name } -PassThru
                                    }
                                    else
                                    {                                    
                                        # Then get all of them
                                        Get-ChildItem -Path $properties.DatabasesRoot |
                                            Where-Object { $_.PsIsContainer }
                                    }
                                } |
                                Select-Object -Property Name,FullName -Unique |
                                Where-Object { 
                                    if( -not $properties.IgnoreDatabases )
                                    {
                                        return $true
                                    }

                                    $dbName = $_.Name                                        
                                    $ignore = $properties.IgnoreDatabases | Where-Object { $dbName -like $_ }
                                    return -not $ignore
                                } |
                                ForEach-Object {
                                    $dbName = $_.Name
                                    $dbProps = @{
                                                    'Name' = $dbName;
                                                    'Root' = $_.FullName;
                                                }
                                    New-Object PsObject -Property $dbProps |
                                        Add-Member -MemberType ScriptProperty -Name MigrationsRoot -Value { Join-Path -Path $this.Root -ChildPath 'Migrations' } -PassThru
                                }
        if( $properties.Databases )
        {
            $properties.Databases = [Object[]]$properties.Databases
        }
        else
        {
            $properties.Databases = @()
        }

        return New-Object PsObject -Property $properties
    }
}
