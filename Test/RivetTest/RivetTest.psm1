
$RTConfigFilePath = 
    $RTDatabasesRoot = 
    $RTDatabaseRoot = 
    $RTDatabaseMigrationRoot =
    $RTServer = 
    $RTRivetPath = 
    $RTRivetSchemaName = 
    $RTDatabaseName =
    $RTDatabaseConnection = $null
                  
$RTRivetSchemaName = 'rivet'
$RTDatabaseName = 'RivetTest'
$RTDatabase2Name = 'RivetTest2'

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
