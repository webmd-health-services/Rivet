
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
    [OutputType([Rivet.Configuration.Configuration])]
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

    Set-StrictMode -Version 'Latest'

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

    filter Get-ConfigProperty
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
            $AsString,

            [Parameter(Mandatory=$true,ParameterSetName='AsHashtable')]
            [Switch]
            # Set the configuration value as a hashtable.
            $AsHashtable
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
            }
            return
        }

        switch ($PSCmdlet.ParameterSetName )
        {
            'AsInt'
            {
                if( -not ($value -is 'int') )
                {
                    Write-ValidationError -Message ('setting ''{0}'' is invalid. It should be a positive integer.' -f $Name)
                    return
                }
                return $value
            }
            'AsList'
            {
                return [Object[]]$value
            }
            'AsPath'
            {
                $path = $value  | Resolve-RivetConfigPath
                if( -not (Test-Path -Path $path -PathType Container) )
                {
                    Write-ValidationError ('path {0} ''{1}'' not found.' -f $Name,$path)
                    return
                }
                return $path
            }
            'AsString'
            {
                return $value
            }
            'AsHashtable'
            {
                $hashtable = @{ }
                Get-Member -InputObject $value -MemberType NoteProperty |
                    ForEach-Object { $hashtable[$_.Name] = $value.($_.Name) }
                return ,$hashtable
            }
        }
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

    $rawConfig = Get-Content -Raw -Path $Path | ConvertFrom-Json
    if( -not $rawConfig )
    {
        Write-Error -Message ('Rivet configuration file ''{0}'' contains invalid JSON.' -f $Path)
        return
    }

    if( $Environment -and -not (Get-Environment) )
    {
        Write-Error ('Environment ''{0}'' not found in ''{1}''.' -f $Environment,$Path)
        return
    }

    $errorCount = $Global:Error.Count

    $sqlServerName = Get-ConfigProperty -Name 'SqlServerName' -Required -AsString
    $dbsRoot = Get-ConfigProperty -Name 'DatabasesRoot' -Required -AsPath
    $connectionTimeout = Get-ConfigProperty -Name 'ConnectionTimeout' -AsInt
    if( $connectionTimeout -eq $null )
    {
        $connectionTimeout = 15
    }

    $commandTimeout = Get-ConfigProperty -Name 'CommandTimeout' -AsInt
    if( $commandTimeout -eq $null )
    {
        $commandTimeout = 30
    }

    if( $Global:Error.Count -ne $errorCount )
    {
        return
    }

    [Rivet.Configuration.Configuration]$configuration = New-Object 'Rivet.Configuration.Configuration' $Path,$Environment,$sqlServerName,$dbsRoot,$connectionTimeout,$commandTimeout

    Get-ConfigProperty -Name 'PluginsRoot' -AsPath | ForEach-Object { $configuration.PluginsRoot.Add( $_ ) }
    $ignoredDatabases = Get-ConfigProperty -Name 'IgnoreDatabases' -AsList
    $targetDatabases = Get-ConfigProperty -Name 'TargetDatabases' -AsHashtable
    if( $targetDatabases )
    {
        $targetDatabases.Keys | ForEach-Object { $configuration.TargetDatabases[$_] = $targetDatabases[$_] }
    }

    if( $Global:Error -ne $errorCount )
    {
        return
    }

    Invoke-Command {
            # Get user-specified databases first
            if( $Database )
            {
                $Database | 
                    Add-Member -MemberType ScriptProperty -Name Name -Value { $this } -PassThru |
                    Add-Member -MemberType ScriptProperty -Name FullName -Value { Join-Path -Path $configuration.DatabasesRoot -ChildPath $this.Name } -PassThru
            }
            else
            {                                    
                # Then get all of them
                Get-ChildItem -Path $configuration.DatabasesRoot |
                    Where-Object { $_.PsIsContainer }
            }
        } |
        Select-Object -Property Name,FullName -Unique |
        Where-Object { 
            if( -not $ignoredDatabases )
            {
                return $true
            }

            $dbName = $_.Name                                        
            $ignore = $ignoredDatabases | Where-Object { $dbName -like $_ }
            return -not $ignore
        } |
        ForEach-Object {
            $dbName = $_.Name
            $db = New-Object 'Rivet.Configuration.Database' $dbName,$_.FullName
            $configuration.Databases.Add( $db )
        }

    return $configuration
}
