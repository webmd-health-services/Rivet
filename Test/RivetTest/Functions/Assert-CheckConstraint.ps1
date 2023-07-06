
function Assert-CheckConstraint
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the constraint.
        $Name,

        [Switch]
        $NotForReplication,

        [Switch]
        $IsDisabled,

        [string]
        $Definition
    )

    $constraint = Get-CheckConstraint -Name $Name

    $constraint | Should -Not -BeNullOrEmpty -Because ('check constraint ''{0}'' not found' -f $Name)

    $constraint.is_not_for_replication | Should -Be $NotForReplication

    if( $IsDisabled )
    {
        $constraint.is_disabled | Should -BeTrue
    }
    else
    {
        $constraint.is_disabled | Should -BeFalse
    }

    if( $PSBoundParameters.ContainsKey('Definition') )
    {
        $constraint.definition | Should -Be $Definition
    }
}
