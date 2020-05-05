
function Remove-PrimaryKey
{
    <#
    .SYNOPSIS
    Removes a primary key from a table.

    .DESCRIPTION
    The `Remove-PrimaryKey` operation removes a primary key from a table.

    .EXAMPLE
    Remove-PrimaryKey 'Cars' -Name 'Car_PK'

    Demonstrates how to remove a primary key whose name is different than the derived name Rivet creates for primary keys.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]
        # The name of the table.
        [String]$TableName,

        # The schema name of the table.  Defaults to `dbo`.
        [String]$SchemaName = 'dbo',

        [Parameter(Position=1)]
        # The name of the primary key to remove.
        [String]$Name
    )

    Set-StrictMode -Version 'Latest'

    [Rivet.Operations.RemovePrimaryKeyOperation]::New($SchemaName, $TableName, $Name)
}
