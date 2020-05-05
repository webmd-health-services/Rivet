
function Remove-Index
{
    <#
    .SYNOPSIS
    Removes an index from a table.

    .DESCRIPTION
    The `Remove-Index` operation removes an index from a table.

    .EXAMPLE
    Remove-Index 'Cars' -Name 'YearIX'

    Demonstrates how to drop an index
    #>
    [CmdletBinding(DefaultParameterSetName='ByDefaultName')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the target table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the target table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ByDefaultName')]
        [string[]]
        # OBSOLETE. Use the `Name` parameter to remove an index.
        $ColumnName,

        [Parameter(ParameterSetName='ByDefaultName')]
        [Switch]
        # OBSOLETE. Use the `Name` parameter to remove an index.
        $Unique,

        [Parameter(Mandatory=$true,ParameterSetName='ByExplicitName')]
        [string]
        # The name of the index to remove.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    # TODO: once generating constraint names is out, remove $columnName and $unique parameters.
    [Rivet.Operations.RemoveIndexOperation]::New($SchemaName, $TableName, $Name, $ColumnName, $Unique)
}
