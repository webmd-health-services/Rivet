
function Remove-DefaultConstraint
{
    <#
    .SYNOPSIS
    Removes the Default Constraint from the database

    .DESCRIPTION
    Removes the Default Constraint from the database.

    .LINK
    Remove-DefaultConstraint

    .EXAMPLE
    Remove-DefaultConstraint 'Cars' -Name 'Cars_Year_DefaultConstraint'

    Demonstrates how to remove a default constraint.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the target table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the target table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The name for the default constraint.
        $Name

    )

    Set-StrictMode -Version 'Latest'

    New-Object 'Rivet.Operations.RemoveDefaultConstraintOperation' $SchemaName, $TableName, $Name
}
