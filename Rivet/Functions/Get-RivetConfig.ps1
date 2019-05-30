
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
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    function Resolve-RivetConfigPath
    {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory,ValueFromPipeline)]
            [string]
            # The path from the rivet config file to resolve.
            $ConfigPath,

            [Switch]
            # The path *must* exist, so resolve it.
            $Resolve
        )

        process
        {
            $originalPath = $ConfigPath
            if( -not [IO.Path]::IsPathRooted( $ConfigPath ) )
            {
                $ConfigPath = Join-Path -Path $configRoot -ChildPath $ConfigPath
            }

            if( $Resolve )
            {
                $resolvedPath = Resolve-Path -Path $ConfigPath | Select-Object -ExpandProperty 'Path'
                if( ($resolvedPath | Measure-Object).Count -gt 1 )
                {
                    Write-ValidationError -Message ('path "{0}" resolves to multiple items: "{1}". Please update the path so that it resolves to only one item, or remove items so that only one remains.' -f $originalPath,($resolvedPath -join '", "'))
                    return
                }
                return $resolvedPath
            }
            else
            {
                return [IO.Path]::GetFullPath( $ConfigPath )
            }
        }
    }

    $currentPropertyName = $null

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

            [Parameter(Mandatory,ParameterSetName='AsInt')]
            [Switch]
            # Set the configuration value as an integer.
            $AsInt,

            [Parameter(Mandatory,ParameterSetName='AsList')]
            [Switch]
            # Set the configuration value as a list of strings.
            $AsList,

            [Parameter(Mandatory,ParameterSetName='AsPath')]
            [Switch]
            # Set the configuration value as a path.
            $AsPath,

            [Parameter(ParameterSetName='AsPath')]
            [Switch]
            # Resolves the path to an actual path. 
            $Resolve,

            [Parameter(Mandatory,ParameterSetName='AsString')]
            [Switch]
            # Set the configuration value as a string.
            $AsString,

            [Parameter(Mandatory,ParameterSetName='AsHashtable')]
            [Switch]
            # Set the configuration value as a hashtable.
            $AsHashtable
        )
        
        $value = $null
        $currentPropertyName = $Name

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
                Write-ValidationError ('is required.')
            }
            return
        }

        switch ($PSCmdlet.ParameterSetName )
        {
            'AsInt'
            {
                if( -not ($value -is [int] -or $value -is [int64]) )
                {
                    Write-ValidationError -Message ('is invalid. It should be an integer but we found a "{0}".' -f $value.GetType().FullName)
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
                $configPath = $value | Resolve-RivetConfigPath -Resolve:$Resolve
                if( -not $configPath )
                {
                    return
                }
                if( -not (Test-Path -Path $configPath -PathType Container) )
                {
                    Write-ValidationError ('path "{0}" not found.' -f $configPath)
                    return
                }
                return $configPath
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
            $envMsg = 'environment "{0}": ' -f $Environment
        }
        $nameMsg = ''
        if( $currentPropertyName )
        {
            $nameMsg = 'property "{0}": ' -f $currentPropertyName
        }
        Write-Error -Message ('Invalid Rivet configuration file "{0}": {1}{2}{3} See about_Rivet_Configuration for more information.' -f $Path,$envMsg,$nameMsg,$Message)
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
        Write-Error ('Rivet configuration file "{0}" not found.' -f $Path)
        return
    }

    $configRoot = Split-Path -Parent -Path $Path

    $rawConfig = Get-Content -Raw -Path $Path | ConvertFrom-Json
    if( -not $rawConfig )
    {
        Write-Error -Message ('Rivet configuration file "{0}" contains invalid JSON.' -f $Path)
        return
    }

    if( $Environment -and -not (Get-Environment) )
    {
        Write-Error ('Environment "{0}" not found in "{1}".' -f $Environment,$Path)
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
    $pluginPaths = Get-ConfigProperty -Name 'PluginPaths' -AsPath -Resolve

    $ignoredDatabases = Get-ConfigProperty -Name 'IgnoreDatabases' -AsList
    $targetDatabases = Get-ConfigProperty -Name 'TargetDatabases' -AsHashtable
    if( $targetDatabases -eq $null )
    {
        $targetDatabases = @{ }
    }

    $order = Get-ConfigProperty -Name 'DatabaseOrder' -AsList

    [Rivet.Configuration.Configuration]$configuration = New-Object 'Rivet.Configuration.Configuration' $Path,$Environment,$sqlServerName,$dbsRoot,$connectionTimeout,$commandTimeout,$pluginPaths

    if( $Global:Error.Count -ne $errorCount )
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
                # Then get all of them in the order requested
                if( $order )
                {
                    foreach( $dbName in $order )
                    {
                        Get-ChildItem -Path $configuration.DatabasesRoot -Filter $dbName -Directory
                    }
                }

                Get-ChildItem -Path $configuration.DatabasesRoot -Exclude $order -Directory
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
            if( $targetDatabases.ContainsKey( $dbName ) )
            {
                foreach( $targetDBName in $targetDatabases[$dbName] )
                {
                    New-Object 'Rivet.Configuration.Database' $targetDBName,$_.FullName
                }
            }
            else
            {
                New-Object 'Rivet.Configuration.Database' $dbName,$_.FullName
            }
        } | 
        ForEach-Object { $configuration.Databases.Add( $_ ) }

    return $configuration
}
