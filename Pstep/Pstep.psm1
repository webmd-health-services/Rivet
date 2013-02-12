
param(
    [Parameter(Mandatory=$true,Position=0)]
    [string]
    # The name of the SQL Server to connect to.
    $SqlServerName,
    
    [Parameter(Mandatory=$true,Position=1)]
    [string]
    # The name of the database to synchronize.
    $Database
)

dir $PSScriptRoot *-*.ps1 |
    ForEach-Object { . $_.FullName }

$server = New-Object Microsoft.SqlServer.Management.Smo.Server ($SqlServerName)
$server.ConnectionContext.LoginSecure = $true
$server.ConnectionContext.Connect()

if( -not $server.Databases.Contains($Database) )
{
    Write-Host ('Creating database {0}.' -f $Database)
    Invoke-Query -Query ('create database {0}' -f $Database) -Database master    
}

$db = $server.Databases[$Database]
if( -not $db.Schemas.Contains( 'pstep' ) )
{
    Write-Host 'Creating migrations schema.'
    Invoke-Query -Query 'create schema pstep'
}

if( -not $db.Tables.Contains( 'Migrations', 'pstep' ) )
{
    Write-Host 'Creating Migrations table.'
    Invoke-Query -Query @"
create table pstep.Migrations (
    ID bigint not null,
    Name nvarchar(50) not null,
    Who nvarchar(50) not null,
    ComputerName nvarchar(50) not null,
    AtUtc datetime not null
)

alter table pstep.Migrations add constraint MigrationsPK primary key (ID)
alter table pstep.Migrations add constraint AtUtcDefault default (GetUtcDate()) for AtUtc
"@
}

Export-ModuleMember -Function * 
