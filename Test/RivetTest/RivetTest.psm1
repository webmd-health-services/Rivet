
param(
    [Parameter(Mandatory=$true)]
    [string]
    # The name of the database.
    $RTName
)

$RTConfigFilePath = 
    $RTDatabasesSourcePath = 
    $RTDatabaseSourcePath = 
    $RTDatabaseSourceName = 
    $RTDatabaseName = 
    $RTDatabasesRoot = 
    $RTDatabaseRoot = 
    $RTDatabaseMigrationRoot =
    $RTServer = 
    $RTRivetPath = 
    $RTRivetSchemaName = 
    $RTDatabaseConnection = 
    $RTMasterConnection = $RTnull
                  
$RTRivetSchemaName = 'rivet'

$RTDatabasesSourcePath = Join-Path $PSScriptRoot ..\Databases -Resolve
$RTDatabaseSourcePath = Join-Path $RTDatabasesSourcePath $RTName 
$RTDatabaseSourcePath = [IO.Path]::GetFullPath( $RTDatabaseSourcePath )
$RTDatabaseSourceName = $RTName

$RTServer = Get-Content (Join-Path $PSScriptRoot ..\Server.txt) -TotalCount 1

$RTRivetPath = Join-Path $PSScriptRoot ..\..\Rivet\rivet.ps1 -Resolve

dir $PSScriptRoot *-*.ps1 |
    Where-Object { $_.BaseName -ne 'Import-RivetTest' } |
    ForEach-Object { . $_.FullName }

$RTMasterConnection = New-SqlConnection -DatabaseName 'master'

. (Join-Path $PSScriptRoot '..\..\Rivet\New-DefaultConstraintName.ps1')
. (Join-Path $PSScriptRoot '..\..\Rivet\New-ForeignKeyConstraintName.ps1')
    
Export-ModuleMember -Function * -Alias * -Variable *
