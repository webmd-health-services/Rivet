
function Test-CheckConstraint
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the constraint.
        $Name
    )

    $constraint = Get-CheckConstraint -Name $Name
    if( $constraint )
    {
        return $true
    }
    else
    {
        return $false
    }
}
