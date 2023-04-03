
function Invoke-Rivet
{
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='New')]
        [Switch]
        # Creates a new migration.
        $New,
    
        [Parameter(Mandatory=$true,ParameterSetName='Push')]
        [Switch]
        # Applies migrations.
        $Push,
    
        [Parameter(Mandatory=$true,ParameterSetName='Pop')]
        [Parameter(Mandatory=$true,ParameterSetName='PopByCount')]
        [Parameter(Mandatory=$true,ParameterSetName='PopByName')]
        [Parameter(Mandatory=$true,ParameterSetName='PopAll')]
        [Switch]
        # Reverts migrations.
        $Pop,
    
        [Parameter(Mandatory=$true,ParameterSetName='Redo')]
        [Switch]
        # Reverts a migration, then re-applies it.
        $Redo,

        [Parameter(Mandatory=$true,ParameterSetName='New',Position=1)]
        [Parameter(ParameterSetName='Push',Position=1)]
        [Parameter(Mandatory=$true,ParameterSetName='PopByName',Position=1)]
        [ValidateLength(1,241)]
        [string[]]
        # The name of the migrations to create, push, or pop. Matches against the migration's ID, Name, or file name (without extension). Wildcards permitted.
        $Name,
    
        [Parameter(Mandatory=$true,ParameterSetName='PopByCount',Position=1)]
        [UInt32]
        # The number of migrations to pop. Default is 1.
        $Count = 1,

        [Parameter(Mandatory=$true,ParameterSetName='PopAll')]
        [Switch]
        # Pop all migrations
        $All,

        [Parameter(ParameterSetName='Pop')]
        [Parameter(ParameterSetName='PopByCount')]
        [Parameter(ParameterSetName='PopByName')]
        [Parameter(ParameterSetName='PopAll')]
        [Parameter(ParameterSetName='DropDatabase')]
        [Parameter(ParameterSetName='Checkpoint')]
        [Switch]
        # Force popping a migration you didn't apply or that is old.
        $Force,

        [Parameter(ParameterSetName='New',Position=2)]
        [Parameter(ParameterSetName='Push')]
        [Parameter(ParameterSetName='Pop')]
        [Parameter(ParameterSetName='PopByCount')]
        [Parameter(ParameterSetName='PopByName')]
        [Parameter(ParameterSetName='PopAll')]
        [Parameter(ParameterSetName='Redo')]
        [Parameter(ParameterSetName='DropDatabase')]
        [Parameter(ParameterSetName='Checkpoint')]
        [Parameter(ParameterSetName='InitializeSchema')]
        [string[]]
        # The database(s) to migrate. Optional.  Will operate on all databases otherwise.
        $Database,

        [Parameter(ParameterSetName='New')]
        [Parameter(ParameterSetName='Push')]
        [Parameter(ParameterSetName='Pop')]
        [Parameter(ParameterSetName='PopByCount')]
        [Parameter(ParameterSetName='PopByName')]
        [Parameter(ParameterSetName='PopAll')]
        [Parameter(ParameterSetName='Redo')]
        [Parameter(ParameterSetName='DropDatabase')]
        [Parameter(ParameterSetName='Checkpoint')]
        [Parameter(ParameterSetName='InitializeSchema')]
        [string]
        # The environment you're working in.  Controls which settings Rivet loads from the `rivet.json` configuration file.
        $Environment,

        [Parameter(ParameterSetName='New')]
        [Parameter(ParameterSetName='Push')]
        [Parameter(ParameterSetName='Pop')]
        [Parameter(ParameterSetName='PopByCount')]
        [Parameter(ParameterSetName='PopByName')]
        [Parameter(ParameterSetName='PopAll')]
        [Parameter(ParameterSetName='Redo')]
        [Parameter(ParameterSetName='DropDatabase')]
        [Parameter(ParameterSetName='Checkpoint')]
        [Parameter(ParameterSetName='InitializeSchema')]
        [string]
        # The path to the Rivet configuration file.  Default behavior is to look in the current directory for a `rivet.json` file.  See `about_Rivet_Configuration` for more information.
        $ConfigFilePath,

        [Parameter(ParameterSetName='DropDatabase')]
        [Switch]
        # Drops the database(s) for the current environment when given. User will be prompted for confirmation when used.
        $DropDatabase,

        [Parameter(ParameterSetName='Checkpoint')]
        [Switch]
        # Checkpoints the current state of the database so that it can be re-created.
        $Checkpoint,

        [Parameter(ParameterSetName='InitializeSchema')]
        [Switch]
        # Initializes the database, including baseline schema. Use the -Checkpoint switch to create a database baseline.
        $InitializeSchema
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    [Rivet.Configuration.Configuration]$settings = Get-RivetConfig -Database $Database -Path $ConfigFilePath -Environment $Environment

    if( -not $settings.Databases )
    {
        Write-Error (@'
Found no databases to migrate. This can be a few things:
 
 * There are no database directories in ''{0}''.  Please create a database directory there or supply an explicit database name with the `Database` parameter.  
 * You supplied an explicit database name, but that database is on the ignore list. Remove it from the ignore list in ''{1}'' or enter a database name that isn't ignored.
 * You supplied an explicit database name, but no directory for migrations exist on the file system (under {0}). Create a migrations directory or enter the name of a database that exists.

'@ -f $settings.DatabasesRoot,$settings.Path)
        return
    }

    Import-RivetPlugin -Path $settings.PluginPaths -ModuleName $settings.PluginModules

    try
    {
        if( $PSCmdlet.ParameterSetName -eq 'New' )
        {
            $settings.Databases | 
                Select-Object -ExpandProperty 'MigrationsRoot' -Unique |
                ForEach-Object { New-Migration -Name $Name -Path $_ }
            return
        }

        if( $DropDatabase )
        {
            # Connect to master as we cannot drop a database if we're connected to it
            Connect-Database -SqlServerName $settings.SqlServerName `
                                    -Database 'Master' `
                                    -ConnectionTimeout $settings.ConnectionTimeout

            $databaseString = ($settings.Databases | Select-Object -ExpandProperty 'Name') -join "', '"
            $query = "select name from sys.databases where name in ('$($databaseString)')"
            $databaseList = Invoke-Query -Query $query

            if( $databaseList )
            {
                $confirmDropDatabase = $false
                if( -not $Force)
                {
                    $confirmQuery = 'Using the `DropDatabase` switch will drop the database(s) for the current ' +
                                    'environment. Do you want to proceed?'
                    
                    $confirmCaption = 'Drop the following database(s)? ' +
                                      (($databaseList | Select-Object -ExpandProperty 'Name') -join ', ')
                    
                    $confirmDropDatabase = $PSCmdlet.ShouldContinue( $confirmQuery, $confirmCaption )
                }

                if( $confirmDropDatabase -or $Force )
                {
                    foreach( $databaseItem in $databaseList )
                    {
                        $query = "DROP DATABASE {0}" -f $databaseItem.Name
                        Invoke-Query -Query $query
                    }
                }
            }
            return
        }

        if( $Checkpoint )
        {
            Checkpoint-Migration -Database $Database -Environment $Environment -ConfigFilePath $ConfigFilePath -Force:$Force
            return
        }

        foreach( $databaseItem in $settings.Databases )
        {
            $databaseName = $databaseItem.Name
            $dbMigrationsPath = $databaseItem.MigrationsRoot
        
            $result = Connect-Database -SqlServerName $settings.SqlServerName `
                                       -Database $databaseName `
                                       -ConnectionTimeout $settings.ConnectionTimeout
            if( -not $result )
            {
                continue
            }
        
            try
            {
                Initialize-Database -Configuration $settings
                if( $InitializeSchema )
                {
                    continue
                }

                $updateParams = @{
                                    Path = $dbMigrationsPath;
                                    Configuration = $settings;
                                }

                if( -not (Test-Path -Path $dbMigrationsPath -PathType Container) )
                {
                    Write-Warning ('{0} database migrations directory ({1}) not found.' -f $databaseName,$dbMigrationsPath)
                    continue
                }
            
                if( $PSBoundParameters.ContainsKey('Name') )
                {
                    $updateParams.Name = $Name    # Join-Path $dbMigrationsPath ("*_{0}.ps1" -f $Name)
                }

                Write-Debug -Message ('# {0}.{1}' -f $Connection.DataSource,$Connection.Database)
            
                if( $pscmdlet.ParameterSetName -eq 'Push' )
                {
                    Update-Database @updateParams
                }
                elseif( $pscmdlet.ParameterSetName -eq 'Pop' )
                {
                    Update-Database -Pop -Count 1 -Force:$Force @updateParams
                }
                elseif( $pscmdlet.ParameterSetName -eq 'PopByName' )
                {
                    Update-Database -Pop -Force:$Force @updateParams
                }
                elseif( $pscmdlet.ParameterSetName -eq 'PopByCount' )
                {
                    Update-Database -Pop -Count $Count -Force:$Force @updateParams
                }
                elseif ( $pscmdlet.ParameterSetName -eq 'PopAll' )
                {
                    Update-Database -Pop -All -Force:$Force @updateParams
                }
                elseif( $pscmdlet.ParameterSetName -eq 'Redo' )
                {
                    Update-Database -Pop -Count 1 @updateParams
                    Update-Database @updateParams
                }
            }
            catch
            {
                $firstException = $_.Exception
                while( $firstException.InnerException )
                {
                    $firstException = $firstException.InnerException
                }
            
                Write-Error ('{0} database migration failed: {1}.' -f $databaseName,$firstException.Message)
            }
        }
    }
    finally
    {
        Disconnect-Database
    }
}

Set-Alias -Name rivet -Value Invoke-Rivet
