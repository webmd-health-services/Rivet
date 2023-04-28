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
        # The name of the table.
        [Parameter(Mandatory, Position=0)]
        [String] $TableName,

        # The schema name of the table.  Defaults to `dbo`.
        [String] $SchemaName = 'dbo',

        # OBSOLETE. Use the `Name` parameter to specify the foreign key to remove.
        [Parameter(Mandatory, Position=1, ParameterSetName='ByDefaultName')]
        [String] $References,

        # OBSOLETE. Use the `Name` parameter to specify the foreign key to remove.
        [Parameter(ParameterSetName='ByDefaultName')]
        [String] $ReferencesSchema = 'dbo',

        # The name of the foreign key to remove.
        [Parameter(Mandatory, ParameterSetName='ByCustomName')]
        [String] $Name
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    if ($PSCmdlet.ParameterSetName -eq 'ByDefaultName')
    {
        $Name = New-ConstraintName -ForeignKey `
                                   -SchemaName $SchemaName `
                                   -TableName $TableName `
                                   -ReferencesSchema $ReferencesSchema `
                                   -ReferencesTableName $References
    }

    [Rivet.Operations.RemoveForeignKeyOperation]::New($SchemaName, $TableName, $Name)
}
