
function Assert-DefaultConstraint
{
    <#
    .SYNOPSIS
    Tests that a default constraint exists for a particular column and table
    #>

    param(
        [Parameter()]
        [string]
        # The table's schema.  Default is `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table
        $TableName,

        [string[]]
        # Array of Column Names
        $ColumnName,

        [string]
        # The name of the constraint.
        $Name,

        [string]
        # The expected expression.
        $Definition
    )

    Set-StrictMode -Version Latest

    if( -not $Name )
    {
        $Name = New-ConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName -Default
    }

    $constraint = Get-DefaultConstraint -Name $Name

    if( (Test-Pester) )
    {
        $constraint | Should -Not -BeNullOrEmpty -Because ('Default constraint ''{0}'' not found.' -f $Name)

        if( $PSBoundParameters.ContainsKey('Expression') )
        {
            $constraint.definition | Should -Be $Definition 
        }
    }
    else
    {
        Assert-NotNull $constraint ('Default constraint ''{0}'' not found.' -f $Name)

        if( $PSBoundParameters.ContainsKey('Expression') )
        {
            Assert-Equal $Definition $constraint.definition
        }
    }
}
