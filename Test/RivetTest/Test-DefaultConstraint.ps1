
function Test-DefaultConstraint
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
        $SchemaName = 'dbo'
    )

    Set-StrictMode -Version Latest

    $name = New-ConstraintName @PSBoundParameters -Default
    $constraint = Get-DefaultConstraint -Name $name
    return ($constraint -ne $null)
}
