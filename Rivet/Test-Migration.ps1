
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
        [Int64]
        $ID,

        [Switch]
        # Returns the migration info.
        $PassThru
    )
    
    $query = 'select * from {0} where ID=@ID' -f $RivetMigrationsTableFullName,$ID
    $info = Invoke-Query -Query $query -Parameter @{ ID = $ID } -Verbose:$false
    if( $info )
    {
        if( $PassThru )
        {
            return $info
        }
        return $true
    }
    return $false
}
