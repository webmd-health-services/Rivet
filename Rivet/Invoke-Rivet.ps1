
function Invoke-Rivet
{
    [CmdletBinding()]
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
        [Switch]
        # Reverts migrations.
        $Pop,
    
        [Parameter(Mandatory=$true,ParameterSetName='Redo')]
        [Switch]
        # Reverts a migration, then re-applies it.
        $Redo,

        [Parameter(Mandatory=$true,ParameterSetName='New',Position=1)]
        [Parameter(ParameterSetName='Push',Position=1)]
        [string]
        # The name of the migration to create/push.  Wildcards accepted when pushing.
        $Name,
    
        [Parameter(ParameterSetName='Pop',Position=1)]
        [UInt32]
        # The number of migrations to pop. Default is 1.
        $Count = 1,

        [Parameter(ParameterSetName='New',Position=2)]
        [Parameter(ParameterSetName='Push')]
        [Parameter(ParameterSetName='Pop')]
        [Parameter(ParameterSetName='Redo')]
        [string[]]
        # The database(s) to migrate. Optional.  Will operate on all databases otherwise.
        $Database,

        [Parameter()]
        [string]
        # The environment you're working in.  Controls which settings Rivet loads from the `rivet.json` configuration file.
        $Environment,

        [Parameter()]
        [string]
        # The path to the Rivet configuration file.  Default behavior is to look in the current directory for a `rivet.json` file.  See `about_Rivet_Configuration` for more information.
        $ConfigFilePath
    )

    $settings = Get-RivetConfig -Database $Database -Path $ConfigFilePath -Environment $Environment

    if( -not $settings.Databases )
    {
        Write-Error ('There are not database directories in ''{0}''.  Please create a database directory there or supply an explicit database name with the `Database` parameter.' -f $settings.DatabasesRoot)
        return
    }

    $settings.Databases | ForEach-Object {

        $databaseName = $_.Name
        $dbScriptsPath = $_.Root
        $dbMigrationsPath = $_.MigrationsRoot
        
        if( $pscmdlet.ParameterSetName -eq 'New' )
        {
            New-Migration -Name $Name -Path $dbMigrationsPath
            return
        }
    
        Connect-Database -SqlServerName $settings.SqlServerName `
                         -Database $databaseName `
                         -ConnectionTimeout $settings.ConnectionTimeout
        
        $Connection.ScriptsPath = $dbScriptsPath

        try
        {
            Initialize-Database

            $updateParams = @{
                                Path = $dbMigrationsPath;
                                DBScriptsPath = $dbScriptsPath;
                             }

            if( -not (Test-Path -Path $dbMigrationsPath -PathType Container) )
            {
                Write-Warning ('{0} database migrations directory ({1}) not found.' -f $databaseName,$dbMigrationsPath)
                return
            }
            
            if( $Name )
            {
                $updateParams.Path = Join-Path $dbMigrationsPath ("*_{0}.ps1" -f $Name)
            }
            
            Write-Host ('# {0}.{1}' -f $Connection.DataSource,$Connection.Database)
            
            if( $pscmdlet.ParameterSetName -eq 'Push' )
            {
                Update-Database @updateParams
            }
            elseif( $pscmdlet.ParameterSetName -eq 'Pop' )
            {
                Update-Database -Pop $Count @updateParams
            }
            elseif( $pscmdlet.ParameterSetName -eq 'Redo' )
            {
                Update-Database -Pop 1 @updateParams
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
        finally
        {
            $Connection.ScriptsPath = $null
            Disconnect-Database
        }
    }
}

Set-Alias -Name rivet -Value Invoke-Rivet
