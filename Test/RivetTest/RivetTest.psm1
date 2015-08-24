
param(
    [Parameter(Mandatory=$true)]
    [string]
    $RivetRoot
)

$RTConfigFilePath = 
    $RTDatabasesRoot = 
    $RTDatabaseRoot = 
    $RTDatabaseMigrationRoot =
    $RTServer = 
    $RTRivetPath = 
    $RTRivetSchemaName = 
    $RTDatabaseName =
    $RTDatabaseConnection = 
    $RTRivetRoot = $null

$RTTimestamp = 20150101000000

$RTRivetRoot = $RivetRoot
                  
$RTRivetSchemaName = 'rivet'
$RTDatabaseName = 'RivetTest'
$RTDatabase2Name = 'RivetTest2'

$serverFilePath = [IO.Path]::GetFullPath((Join-Path -Path $RTRivetRoot -ChildPath '..\Server.txt'))
if( -not (Test-Path -Path $serverFilePath -PathType Leaf) )
{
    Write-Error ('File ''{0}'' not found. Please create this file. It should contain the name of the SQL Server instance tests should use.' -f $serverFilePath)
}
else
{

    $RTServer = Get-Content $serverFilePath -TotalCount 1
    if( -not $RTServer )
    {
        Write-Error ('Database server not found. Please update ''{0}'' with the name of the SQL Server instance tests should use.' -f $serverFilePath)
    }
}

$RTRivetPath = Join-Path -Path $RivetRoot -ChildPath 'rivet.ps1' -Resolve

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
