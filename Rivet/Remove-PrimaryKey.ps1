
function Remove-PrimaryKey
{
    <#
    .SYNOPSIS
    Removes a primary key from an existing table that has a primary key.

    .DESCRIPTION
    Removes a primary key to a table.

    .LINK
    Remove-PrimaryKey

    .EXAMPLE
    Remove-PrimaryKey -TableName Cars 

    Removes the primary key on the `Cars` table.

    .EXAMPLE
    Remove-PrimaryKey 'Cars' -Name 'Car_PK'

    Demonstrates how to remove a primary key whose name is different than the derived name Rivet creates for primary keys.
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

        [Parameter(Mandatory=$true,ParameterSetName='ByCustomName')]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    if ($PSBoundParameters.containskey("Name"))
    {
        New-Object 'Rivet.Operations.RemovePrimaryKeyOperation' $SchemaName, $TableName, $Name
    }
    else 
    {
        New-Object 'Rivet.Operations.RemovePrimaryKeyOperation' $SchemaName, $TableName
    }
}
