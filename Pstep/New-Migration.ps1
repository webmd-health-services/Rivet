
function New-Migration
{
    <#
    .SYNOPSIS
    Creates a new migration script.
    
    .DESCRIPTION
    Creates a migration script with a given name.  The script is prefixed with the current timestamp (e.g. yyyyMMddHHmmss).  The script is created in `$Path\$Database\Migrations`.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the migration to create.
        $Name,
        
        [Parameter(Mandatory=$true)]
        [string[]]
        # The databases where the migration script(s) will be run/applied.
        $Database,
        
        [Parameter(Mandatory=$true)]
        [string]
        # The root where scripts for all databases are kept.  Migrations will be created in Migrations directory, under a parent directory for each database, e.g. `$Path\$Database\Migrations`.
        $Path
    )

    if( -not (Test-Path -Path $Path -PathType Container) )
    {
        Write-Host ('Creating databases directory {0}.' -f $Path)
        $null = New-Item -Path $Path -ItemType Directory
    }
    
    $Database | ForEach-Object {
        $dbRootPath = Join-Path $Path $_
        if( -not (Test-Path -Path $dbRootPath -PathType Container) )
        {
            Write-Host ('Creating {0} database directory {1}.' -f $_,$dbRootPath)
            $null = New-Item -Path $dbRootPath -ItemType Directory
        }
        
        $dbMigrationPath = Join-Path $dbRootPath 'Migrations'
        if( -not (Test-Path -Path $dbMigrationPath -PathType Container) )
        {
            Write-Host ('Creating {0} database migrations directory {1}.' -f $_,$dbMigrationPath)
            $null = New-Item -Path $dbMigrationPath -ItemType Directory
        }
        
        $id = (Get-Date).ToString('yyyyMMddHHmmss')
        $filename = '{0}_{1}.ps1' -f $id,$Name

        $migrationPath = Join-Path $dbMigrationPath $filename
        New-Item -Path $migrationPath -Force -ItemType File

        @"

        function Push-Migration()
        {
            Invoke-Query -Query @'
        '@
        }

        function Pop-Migration()
        {
            Invoke-Query -Query @'
        '@
        }
"@ | Out-File -FilePath $migrationPath -Encoding OEM

    }
    
}