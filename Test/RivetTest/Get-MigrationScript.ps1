
function Get-MigrationScript
{
    param(
    )

    $migrationDir = Join-Path $DatabaseRoot Migrations -Resolve
    Get-ChildItem $migrationDir *.ps1 | Sort-Object BaseName
}