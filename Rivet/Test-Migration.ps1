
function Test-Migration
{
    <#
    .SYNOPSIS
    Tests if a migration was applied to the database.
    
    .DESCRIPTION
    Returns `true` if a migration with the given ID has already been applied.  `False` otherwise.
    
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
    
    $query = 'select ID, Name, Who, AtUtc from {0} where ID=@ID' -f $RivetMigrationsTableFullName,$ID
    $info = Invoke-Query -Query $query -Parameter @{ ID = $ID } -Verbose:$false
    if( $info )
    {
        Write-Verbose ('{0}   {1,-35} {2,14:00000000000000}_{3}' -f $info.AtUtc.ToLocalTime().ToString('yyyy-mm-dd HH:mm'),$info.Who,$info.ID,$info.Name)
        if( $PassThru )
        {
            return $info
        }
        return $true
    }
    return $false
}
