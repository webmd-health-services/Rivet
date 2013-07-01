
function Test-Table
{
    param(
        $Name
    )
    return Test-DatabaseObject -Table -Name $Name
}
