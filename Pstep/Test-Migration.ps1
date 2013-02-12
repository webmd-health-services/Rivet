
function Test-Migration
{
    <#
    .SYNOPSIS
    Tests if a migration was applied to the database.
    
    .DESCRIPTION
    Returns `true` if a migration witht he given ID has already been applied.  `False` otherwise.
    
    .EXAMPLE
    Test-Migration -ID 20120211235838
    
    Returns `True` if a migration with ID `20120211235838` already exists or `False` if it doesn't.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [UInt64]
        $ID
    )
    
    $migration = Invoke-Query -Query ('select count(*) as Count from migrations.Migrations where ID={0}' -f $ID)
    return ( $migration.Count -gt 0 )
}
