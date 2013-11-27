
function Assert-DefaultConstraint
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

        [string]
        # The expected expression.
        $Definition
    )

    Set-StrictMode -Version Latest

    $name = New-ConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName -Default

    $constraint = Get-DefaultConstraint -Name $name
    Assert-NotNull $constraint ('Default constraint ''{0}'' not found.' -f $name)

    if( $PSBoundParameters.ContainsKey('Expression') )
    {
        Assert-Equal $Definition $constraint.definition
    }
}