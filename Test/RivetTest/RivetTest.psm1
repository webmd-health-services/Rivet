
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
    $RTDatabaseConnection = $null
                  
$RTRivetSchemaName = 'rivet'
$RTName = 'RivetTest'

$RTDatabasesSourcePath = Join-Path $PSScriptRoot ..\Databases -Resolve
$RTDatabaseSourcePath = Join-Path $RTDatabasesSourcePath $RTName 
$RTDatabaseSourcePath = [IO.Path]::GetFullPath( $RTDatabaseSourcePath )

$RTDatabaseSourceName = $RTName

$RTServer = Get-Content (Join-Path $PSScriptRoot ..\Server.txt) -TotalCount 1

$RTRivetPath = Join-Path $PSScriptRoot ..\..\Rivet\rivet.ps1 -Resolve

dir $PSScriptRoot *-*.ps1 |
    Where-Object { $_.BaseName -ne 'Import-RivetTest' } |
    ForEach-Object { . $_.FullName }

if( -not $RTDatabaseConnection -or $RTDatabaseConnection.State -ne [Data.ConnectionSTate]::Open )
{
    $RTDatabaseConnection = New-SqlConnection -Database 'master'
}

. (Join-Path $PSScriptRoot '..\..\Test\RivetTest\New-ConstraintName.ps1')
. (Join-Path $PSScriptRoot '..\..\Test\RivetTest\New-ForeignKeyConstraintName.ps1')
    
Export-ModuleMember -Function * -Alias * -Variable *
