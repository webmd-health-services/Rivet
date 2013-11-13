
function Assert-defaultConstraint
{
    <#
    .SYNOPSIS
    Tests that a default constraint exists for a particular column and table
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table
        $TableName,

        [string[]]
        # Array of Column Names
        $ColumnName,

        [Parameter()]
        [string]
        # The table's schema.  Default is `dbo`.
        $SchemaName = 'dbo',

        [Switch]
        # Test that the default constraint has been removed
        $TestNoDefault

    )

    Set-StrictMode -Version Latest

    $default_constraint = Get-DefaultConstraint
    $expected_constraint_name = @(New-ConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName -Default)

    if ($TestNoDefault)
    {
        if ($default_constraint -isnot 'Object[]')
        {
            Assert-Equal "DF_rivet_Activity_AtUtc" $default_constraint.name
        }
        else
        {
            Assert-Equal "DF_rivet_Activity_AtUtc" $default_constraint[0].name
        }
    }
    else
    {
        Assert-NotNull $default_constraint ('There are no default constraints in the database')
        Assert-Equal $expected_constraint_name $default_constraint[1].name
    }
}