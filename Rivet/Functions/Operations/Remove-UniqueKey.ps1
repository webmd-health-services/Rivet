
function Remove-UniqueKey
{
    <#
    .SYNOPSIS
    Removes the Unique Constraint from the database

    .DESCRIPTION
    Removes the Unique Constraint from the database.

    .EXAMPLE
    Remove-UniqueKey 'Cars' -Name 'YearUK'

    Demonstrates how to remove a unique key whose name is different than the name Rivet derives for unique keys.
    #>

    [CmdletBinding(DefaultParameterSetName='ByDefaultName')]
    param(
        [Parameter(Mandatory,Position=0)]
        # The name of the target table.
        [String]$TableName,

        [Parameter()]
        [String]
        # The schema name of the target table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory,Position=1,ParameterSetName='ByDefaultName')]
        # OBSOLETE. Use the `Name` parameter to specify the name of the unique key to remove.
        [String[]]$ColumnName,

        [Parameter(Mandatory,Position=1,ParameterSetName='ByExplicitName')]
        # The name of the unique key to remove.
        [String]$Name
    )

    Set-StrictMode -Version 'Latest'

    New-Object 'Rivet.Operations.RemoveUniqueKeyOperation' $SchemaName, $TableName, $Name, $ColumnName
}
