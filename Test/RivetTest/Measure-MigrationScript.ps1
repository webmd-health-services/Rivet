
function Measure-MigrationScript
{
    param(
    )

    Get-MigrationScript | 
        Measure-Object | 
        Select-Object -ExpandProperty Count
}