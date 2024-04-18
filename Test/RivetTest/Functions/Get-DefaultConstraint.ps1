
function Get-DefaultConstraint
{
    <#
    .SYNOPSIS
    Gets the default constraints in a database.
    #>
    param(
        # The name of the default constraint to get.
        [String] $Name,

        [String] $DatabaseName
    )

    Set-StrictMode -Version Latest

    $query = @'
    select *
    from sys.default_constraints
'@
    if( $Name )
    {
        $query = @'
{0}
    where
        [name] = '{1}'
'@ -f $query,$Name
    }

    Invoke-RivetTestQuery -Query $query -DatabaseName $DatabaseName

}
