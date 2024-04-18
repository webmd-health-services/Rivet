
function Get-MigrationScript
{
    param(
        [String] $In = $RTDatabaseRoot
    )

    Set-StrictMode -Version Latest

    $migrationDir = Join-Path -Path $In -ChildPath 'Migrations' -Resolve
    Get-ChildItem $migrationDir *.ps1 | Sort-Object BaseName
}
