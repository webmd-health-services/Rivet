function Remove-ForeignKey
{
    <#
    .SYNOPSIS
    Removes a foreign key from an existing table that has a foreign key.

    .DESCRIPTION
    Removes a foreign key to a table.

    .LINK
    Remove-ForeignKey

    .EXAMPLE
    Remove-ForeignKey -TableName Cars -References Year,Make,Model

    Removes a Foreign key to the `Cars` table on the `Year`, `Make`, and `Model` columns.

    .EXAMPLE
    Remove-ForeignKey 'Cars' -Name 'FK_Cars_Year'

    Demonstrates how to remove a foreign key that has a name different than Rivet's derived name.
    #>
    [CmdletBinding()]
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
        # The string that references the table
        $References,

        [Parameter(ParameterSetName='ByDefaultName')]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $ReferencesSchema = 'dbo',

        [Parameter(Mandatory=$true,ParameterSetName='ByCustomName')]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    if( $PSBoundParameters.ContainsKey("Name") )
    {
        $op = New-Object 'Rivet.Operations.RemoveForeignKeyOperation' $SchemaName, $TableName, $Name
        Write-Host (' {0}.{1} -{2}' -f $SchemaName,$TableName,$Name)
    }
    else 
    {
        $op = New-Object 'Rivet.Operations.RemoveForeignKeyOperation' $SchemaName, $TableName, $ReferencesSchema, $References
        Write-Host (' {0}.{1} -{2}' -f $SchemaName,$TableName,$op.Name)
    }

    Invoke-MigrationOperation -Operation $op
    
}
