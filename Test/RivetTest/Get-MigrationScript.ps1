
function Get-MigrationScript
{
    param(
    )

    Set-StrictMode -Version Latest
    
    $migrationDir = Join-Path $RTDatabaseRoot Migrations -Resolve
    Get-ChildItem $migrationDir *.ps1 | Sort-Object BaseName
}