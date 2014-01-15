
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
    
    $query = 'select count(*) as Count from {0} where ID={1}' -f $RivetMigrationsTableFullName,$ID
    $migrationCount = Invoke-Query -Query $query -AsScalar -Verbose:$false
    return ( $migrationCount -gt 0 )
}
