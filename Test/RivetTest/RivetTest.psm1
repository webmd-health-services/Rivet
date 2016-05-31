
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

$serverFileDirs = @( 
                        (Join-Path -Path $PSScriptRoot -ChildPath '..' -Resolve),
                        (Join-Path -Path $env:APPDATA -ChildPath 'Rivet'),
                        (Join-Path -Path $env:ProgramData -ChildPath 'Rivet')
                  )
$serverFilePath = $serverFileDirs |
                      ForEach-Object { Join-Path -Path $_ -ChildPath 'Server.txt' } |
                      Where-Object { Test-Path -Path $_ -PathType Leaf } |
                      Select-Object -First 1
if( -not $serverFilePath )
{
    throw ('File ''Server.txt'' not found. Please create this file. It should contain the name of the SQL Server instance tests should use. It should be in one of these directories:{0} * {1}' -f [Environment]::NewLine,($serverFileDirs -join ('{0} * ' -f[Environment]::NewLine)))
}
else
{

    $RTServer = Get-Content $serverFilePath -TotalCount 1
    if( -not $RTServer )
    {
        throw ('Database server not found. Please update ''{0}'' with the name of the SQL Server instance tests should use.' -f $serverFilePath)
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
