
function Remove-UniqueKey
{
    <#
    .SYNOPSIS
    Removes the Unique Constraint from the database

    .DESCRIPTION
    Removes the Unique Constraint from the database.

    .LINK
    Remove-UniqueConstraint

    .EXAMPLE
    Remove-UniqueConstraint -TableName Cars -Column Year

    Drops a Unique Constraint of column 'Year' in the table 'Cars'

    .EXAMPLE
    Remove-UniqueKey 'Cars' -Name 'YearUK'

    Demonstrates how to remove a unique key whose name is different than the name Rivet derives for unique keys.
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

        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The name for the unique key.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    New-Object 'Rivet.Operations.RemoveUniqueKeyOperation' $SchemaName, $TableName, $Name
}
