
function Invoke-Pstep
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
        # The name of the migration to create/push.  Wildcards accepted when pushing/popping.
        $Name,
    
        [Parameter(ParameterSetName='Pop',Position=1)]
        [UInt32]
        # The number of migrations to pop. Default
        $Count = 1,
    
        [Parameter(Mandatory=$true,ParameterSetName='Push')]
        [Parameter(Mandatory=$true,ParameterSetName='Pop')]
        [Parameter(Mandatory=$true,ParameterSetName='Redo')]
        [string]
        # The SQL Server to connect to, e.g. `.\Instance`.
        $SqlServerName,
    
        [Parameter(Mandatory=$true,ParameterSetName='New',Position=2)]
        [Parameter(Mandatory=$true,ParameterSetName='Push')]
        [Parameter(Mandatory=$true,ParameterSetName='Pop')]
        [Parameter(Mandatory=$true,ParameterSetName='Redo')]
        [string[]]
        # The databases to migrate.
        $Database,
    
        [Parameter(Mandatory=$true,ParameterSetName='New',Position=3)]
        [Parameter(Mandatory=$true,ParameterSetName='Push')]
        [Parameter(Mandatory=$true,ParameterSetName='Pop')]
        [Parameter(Mandatory=$true,ParameterSetName='Redo')]
        [string]
        # The directory where the database scripts are kept.  If `$Database` is singular, migrations are assumed to be in `$Path\$Database\Migrations`.  If `$Database` contains multiple items, `$Path` is assumed to point to a directory which contains directories for each database (e.g. `$Path\$Database[$i]`) and migrations are assumed to be in `$Path\$Database[$i]\Migrations`.
        $Path,

        [Parameter(Mandatory=$true,ParameterSetName='Help')]
        [AllowNull()]
        [AllowEmptyString()]
        [Switch]
        # Display Help.
        $Help,
    
        [Parameter(ParameterSetName='Help',Position=0)]
        [string]
        # The help topic to display.
        $TopicName,
    
        [Parameter(ParameterSetName='Push')]
        [Parameter(ParameterSetName='Pop')]
        [Parameter(ParameterSetName='Redo')]
        [UInt32]
        # The time (in seconds) to wait for a connection to open. The default is 15 seconds.
        $ConnectionTimeout = 15
    )

    if( $pscmdlet.ParameterSetName -eq 'Help' )
    {
        if( $TopicName )
        {
            Get-Help $TopicName
        }
        else
        {
            Get-Help about_Pstep
        }
        return
    }

    if( $pscmdlet.ParameterSetName -eq 'New' )
    {
        New-Migration -Name $Name -Database $Database -Path $Path
        exit $error.Count
    }
    
    $singleDatabase = ( $Database.Length -eq 1 )

    $Database | ForEach-Object {

        $databaseName = $_
        
        Connect-Database -SqlServerName $SqlServerName -Database $databaseName -ConnectionTimeout $ConnectionTimeout
        
        if( $singleDatabase )
        {
            $Connection.ScriptsPath = $Path
        }
        else
        {
            $Connection.ScriptsPath = Join-Path $Path $databaseName
        }
        
        try
        {
            Initialize-Database

            $dbMigrationsPath = Join-Path $Connection.ScriptsPath Migrations
            if( -not (Test-Path -Path $dbMigrationsPath -PathType Container) )
            {
                Write-Warning ('{0} database migrations directory ({1}) not found.' -f $databaseName,$dbMigrationsPath)
                return
            }
            
            if( $Name )
            {
                $dbMigrationsPath = Join-Path $dbMigrationsPath ("*_{0}.ps1" -f $Name)
            }
            
            Write-Host ('# {0}.{1}' -f $Connection.DataSource,$Connection.Database)
            
            if( $pscmdlet.ParameterSetName -eq 'Push' )
            {
                Update-Database -Path $dbMigrationsPath
            }
            elseif( $pscmdlet.ParameterSetName -eq 'Pop' )
            {
                Update-Database -Pop $Count -Path $dbMigrationsPath
            }
            elseif( $pscmdlet.ParameterSetName -eq 'Redo' )
            {
                Update-Database -Pop 1 -Path $dbMigrationsPath
                Update-Database -Path $dbMigrationsPath
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
            Disconnect-Database
        }
    }
}

Set-Alias -Name pstep -Value Invoke-Pstep
