
function Invoke-Rivet
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Creates a new migration.
        [Parameter(Mandatory, ParameterSetName='New')]
        [switch] $New,

        # Applies migrations.
        [Parameter(Mandatory, ParameterSetName='Push')]
        [switch] $Push,

        # Reverts migrations.
        [Parameter(Mandatory, ParameterSetName='Pop')]
        [Parameter(Mandatory, ParameterSetName='PopByCount')]
        [Parameter(Mandatory, ParameterSetName='PopByName')]
        [Parameter(Mandatory, ParameterSetName='PopAll')]
        [switch] $Pop,

        # Reverts a migration, then re-applies it.
        [Parameter(Mandatory, ParameterSetName='Redo')]
        [switch] $Redo,

        # The name of the migrations to create, push, or pop. Matches against the migration's ID, Name, or file name (without extension). Wildcards permitted.
        [Parameter(Mandatory, ParameterSetName='New',Position=1)]
        [Parameter(ParameterSetName='Push', Position=1)]
        [Parameter(Mandatory, ParameterSetName='PopByName',Position=1)]
        [ValidateLength(1,241)]
        [String[]] $Name,

        # The number of migrations to pop. Default is 1.
        [Parameter(Mandatory, ParameterSetName='PopByCount',Position=1)]
        [UInt32] $Count,

        # Pop all migrations
        [Parameter(Mandatory, ParameterSetName='PopAll')]
        [switch] $All,

        # Force popping a migration you didn't apply or that is old.
        [Parameter(ParameterSetName='Pop')]
        [Parameter(ParameterSetName='PopByCount')]
        [Parameter(ParameterSetName='PopByName')]
        [Parameter(ParameterSetName='PopAll')]
        [Parameter(ParameterSetName='DropDatabase')]
        [Parameter(ParameterSetName='Checkpoint')]
        [switch] $Force,

        # The database(s) to migrate. Optional.  Will operate on all databases otherwise.
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
        [String[]] $Database,

        # The environment you're working in.  Controls which settings Rivet loads from the `rivet.json` configuration file.
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
        [String] $Environment,

        # The path to the Rivet configuration file.  Default behavior is to look in the current directory for a
        # `rivet.json` file.  See `about_Rivet_Configuration` for more information.
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
        [String] $ConfigFilePath,

        # Drops the database(s) for the current environment when given. User will be prompted for confirmation when
        # used.
        [Parameter(ParameterSetName='DropDatabase')]
        [switch] $DropDatabase,

        # Checkpoints the current state of the database so that it can be re-created.
        [Parameter(ParameterSetName='Checkpoint')]
        [switch] $Checkpoint,

        # Initializes the database, including baseline schema. Use the -Checkpoint switch to create a database baseline.
        [Parameter(ParameterSetName='InitializeSchema')]
        [switch] $InitializeSchema
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $session = New-RivetSession -ConfigurationPath $ConfigFilePath -Database $Database -Environment $Environment

    if (-not $session.Databases)
    {
        Write-Error (@'
Found no databases to migrate. This can be a few things:

 * There are no database directories in ''{0}''.  Please create a database directory there or supply an explicit database name with the `Database` parameter.
 * You supplied an explicit database name, but that database is on the ignore list. Remove it from the ignore list in ''{1}'' or enter a database name that isn't ignored.
 * You supplied an explicit database name, but no directory for migrations exist on the file system (under {0}). Create a migrations directory or enter the name of a database that exists.

'@ -f $session.DatabasesRoot,$session.Path)
        return
    }

    if (-not $PSBoundParameters.ContainsKey('Count'))
    {
        $Count = 1
    }

    Import-RivetPlugin -Path $session.PluginPaths -ModuleName $session.PluginModules

    if( $PSCmdlet.ParameterSetName -eq 'New' )
    {
        $session.Databases |
            Select-Object -ExpandProperty 'MigrationsRoot' -Unique |
            ForEach-Object { New-Migration -Name $Name -Path $_ }
        return
    }

    if( $DropDatabase )
    {
        # Connect to master as we cannot drop a database if we're connected to it
        Connect-Database -Session $session -Name 'master'

        try
        {
            $databaseString = ($session.Databases | Select-Object -ExpandProperty 'Name') -join "', '"
            $query = "select name from sys.databases where name in ('${databaseString}')"
            $databaseList = Invoke-Query -Session $session -Query $query

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
                        $query = "drop database $($databaseItem.Name)"
                        Invoke-Query -Session $session -Query $query
                    }
                }
            }
        }
        finally
        {
            Disconnect-Database -Session $session
        }
        return
    }

    if( $Checkpoint )
    {
        Checkpoint-Migration -Session $session -Force:$Force
        return
    }

    foreach ($databaseItem in $session.Databases)
    {
        $databaseName = $databaseItem.Name
        $dbMigrationsPath = $databaseItem.MigrationsRoot

        $result = Connect-Database -Session $session -Name $databaseName
        if (-not $result)
        {
            continue
        }

        try
        {
            Initialize-Database -Session $session
            if( $InitializeSchema )
            {
                continue
            }

            $updateParams = @{
                Path = $dbMigrationsPath;
                Session = $session;
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

            $conn = $session.Connection
            Write-Debug -Message "# $($conn.DataSource).$($conn.Database)"

            if( $PSCmdlet.ParameterSetName -eq 'Push' )
            {
                Update-Database @updateParams
            }
            elseif( $PSCmdlet.ParameterSetName -eq 'Pop' )
            {
                Update-Database -Pop -Count 1 -Force:$Force @updateParams
            }
            elseif( $PSCmdlet.ParameterSetName -eq 'PopByName' )
            {
                Update-Database -Pop -Force:$Force @updateParams
            }
            elseif( $PSCmdlet.ParameterSetName -eq 'PopByCount' )
            {
                Update-Database -Pop -Count $Count -Force:$Force @updateParams
            }
            elseif ( $PSCmdlet.ParameterSetName -eq 'PopAll' )
            {
                Update-Database -Pop -All -Force:$Force @updateParams
            }
            elseif( $PSCmdlet.ParameterSetName -eq 'Redo' )
            {
                Update-Database -Pop -Count 1 @updateParams
                Update-Database @updateParams
            }
        }
        finally
        {
            Disconnect-Database -Session $session
        }
    }
}

Set-Alias -Name 'rivet' -Value 'Invoke-Rivet'
