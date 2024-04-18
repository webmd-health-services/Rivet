
function Measure-MigrationScript
{
    param(
        [String] $In
    )

    Get-MigrationScript -In $In |
        Measure-Object |
        Select-Object -ExpandProperty Count
}
