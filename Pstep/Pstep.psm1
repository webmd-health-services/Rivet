
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
    Where-Object { $_.BaseName -ne 'Import-Pstep' } |
    ForEach-Object { . $_.FullName }
    
Initialize-Database

Export-ModuleMember -Function Update-Database
