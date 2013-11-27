
function Assert-CheckConstraint
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the constraint.
        $Name,

        [Switch]
        $NotForReplication,

        [string]
        $Definition
    )

    $query = @'
select * from sys.check_constraints where name = '{0}'
'@ -f $Name
    $constraint = Invoke-RivetTestQuery -Query $query

    Assert-NotNull $constraint ('check constraint ''{0}'' not found' -f $Name)

    Assert-Equal $NotForReplication $constraint.is_not_for_replication

    if( $PSBoundParameters.ContainsKey('Definition') )
    {
        Assert-Equal $Definition $constraint.definition
    }
}