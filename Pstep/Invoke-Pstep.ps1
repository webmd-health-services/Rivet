
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
        [Parameter(ParameterSetName='Push')]
        [Parameter(ParameterSetName='Redo')]
        [string]
        # The name of the migration to create/push/pop/redo.  Wildcards accepted when pushing/popping.
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
        # The root directory where all scripts for all databases are kept.  Migrations are assumed to be in `$Path\$Database\Migrations`.
        $Path,
        
        [UInt32]
        # The time (in seconds) to wait for a connection to open. The default is 15 seconds.
        $ConnectionTimeout = 15
    )

    if( $pscmdlet.ParameterSetName -eq 'New' )
    {
        New-Migration -Name $Name -Database $Database -Path $Path
        exit $error.Count
    }

    $Database | ForEach-Object {

        $databaseName = $_
        
        Connect-Database -SqlServerName $SqlServerName -Database $databaseName -ConnectionTimeout $ConnectionTimeout
        
        try
        {
            Initialize-Database

            $dbMigrationsPath = Join-Path $Path ('{0}\Migrations' -f $databaseName)
            if( -not (Test-Path -Path $dbMigrationsPath -PathType Container) )
            {
                Write-Warning ('{0} database migrations directory ({1}) not found.' -f $databaseName,$dbMigrationsPath)
                return
            }
            
            if( $Name )
            {
                $dbMigrationsPath = Join-Path $dbMigrationsPath ("*_{0}.ps1" -f $Name)
            }
            
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