
function Assert-Table
{
    param(
        $Name
    )
    Assert-True (Test-DatabaseObject -Table -Name $Name) ('table {0} not found' -f $Name)
}
