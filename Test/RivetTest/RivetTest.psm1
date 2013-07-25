
param(
    [Parameter(Mandatory=$true)]
    [string]
    # The name of the database.
    $Name
)

$ConfigFilePath = 
    $DatabasesSourcePath = 
    $DatabaseSourcePath = 
    $DatabaseSourceName = 
    $DatabaseName = 
    $DatabasesRoot = 
    $DatabaseRoot = 
    $Server = 
    $RivetPath = 
    $RivetSchemaName = 
    $DatabaseConnection = 
    $MasterConnection = $null
                  
$RivetSchemaName = 'rivet'

$DatabasesSourcePath = Join-Path $PSScriptRoot ..\Databases -Resolve
$DatabaseSourcePath = Join-Path $DatabasesSourcePath $Name -Resolve
$DatabaseSourceName = $Name

$Server = Get-Content (Join-Path $PSScriptRoot ..\Server.txt) -TotalCount 1

$RivetPath = Join-Path $PSScriptRoot ..\..\Rivet\rivet.ps1 -Resolve

dir $PSScriptRoot *-*.ps1 |
    Where-Object { $_.BaseName -ne 'Import-RivetTest' } |
    ForEach-Object { . $_.FullName }

$MasterConnection = New-SqlConnection -DatabaseName 'master'

. (Join-Path $PSScriptRoot '..\..\Rivet\New-DefaultConstraintName.ps1')
    
Export-ModuleMember -Function * -Alias * -Variable *
