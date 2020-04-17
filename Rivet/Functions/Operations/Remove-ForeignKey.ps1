function Remove-ForeignKey
{
    <#
    .SYNOPSIS
    Removes a foreign key from an existing table that has a foreign key.

    .DESCRIPTION
    Removes a foreign key to a table.

    .EXAMPLE
    Remove-ForeignKey 'Cars' -Name 'FK_Cars_Year'

    Demonstrates how to remove a foreign key that has a name different than Rivet's derived name.
    #>
    [CmdletBinding(DefaultParameterSetName='ByDefaultName')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ByDefaultName')]
        [string]
        # OBSOLETE. Use the `Name` parameter to specify the foreign key to remove.
        $References,

        [Parameter(ParameterSetName='ByDefaultName')]
        [string]
        # OBSOLETE. Use the `Name` parameter to specify the foreign key to remove.
        $ReferencesSchema = 'dbo',

        [Parameter(Mandatory=$true,ParameterSetName='ByCustomName')]
        [string]
        # The name of the foreign key to remove.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    [Rivet.Operations.RemoveForeignKeyOperation]::New($SchemaName, $TableName, $Name)
}
