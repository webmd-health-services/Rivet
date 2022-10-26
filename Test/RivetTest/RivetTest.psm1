
param(
    [String]$RivetRoot
)

$RTConfigFilePath = 
    $RTDatabasesRoot = 
    $RTDatabaseRoot = 
    $RTDatabaseMigrationRoot =
    $RTServer = 
    $RTRivetPath = 
    $RTRivetSchemaName = 
    $RTDatabaseName =
    $RTTestRoot = 
    $RTLastMigrationFailed = $null

$RTTimestamp = 20150101000000

if( -not $RivetRoot )
{
    $RivetRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Rivet' -Resolve
}
                  
$RTRivetSchemaName = 'rivet'
$RTDatabaseName = 'RivetTest'
$RTDatabase2Name = 'RivetTest2'
$script:firstMigrationId = [Int64]'00010101000000' # 1/1/1 00:00:00

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
    throw ('File "Server.txt" not found. Please create this file. It should contain the name of the SQL Server instance tests should use. It should be in one of these directories:{0} * {1}' -f [Environment]::NewLine,($serverFileDirs -join ('{0} * ' -f[Environment]::NewLine)))
}
else
{

    $RTServer = Get-Content $serverFilePath -TotalCount 1
    if( -not $RTServer )
    {
        throw ('Database server not found. Please update "{0}" with the name of the SQL Server instance tests should use.' -f $serverFilePath)
    }
}

if( -not $RivetRoot )
{
    $RivetRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Rivet' -Resolve
}

$RTRivetPath = Join-Path -Path $RivetRoot -ChildPath 'rivet.ps1' -Resolve


$functionsDir = Join-Path -Path $PSScriptRoot -ChildPath 'Functions'
if( (Test-Path -Path $functionsDir -PathType Container) )
{
    Get-ChildItem -Path $functionsDir -Filter '*.ps1' |
        Where-Object { $_.BaseName -ne 'Import-RivetTest' } |
        ForEach-Object { . $_.FullName }

}

$exportsPath = Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest.Exports.ps1'
if( (Test-Path -Path $exportsPath -PathType Leaf) )
{
    . $exportsPath
}
