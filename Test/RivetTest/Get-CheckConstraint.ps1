
function Get-CheckConstraint
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the constraint.
        $Name
    )

    $query = @'
select * from sys.check_constraints where name = '{0}'
'@ -f $Name
    Invoke-RivetTestQuery -Query $query
}
