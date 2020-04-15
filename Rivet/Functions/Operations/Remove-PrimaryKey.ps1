
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

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ByCustomName')]
        [string]
        # The name of the primary key to remoe.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    if( $PSCmdlet.ParameterSetName -eq 'ByDefaultName' )
    {
        Write-Warning ('Remove-PrimaryKey''s Name parameter will be required in a future version of Rivet. Please use the Name parameter to remove the primary key.')
        $Name = New-ConstraintName -PrimaryKey -SchemaName $SchemaName -TableName $TableName
    }

    New-Object 'Rivet.Operations.RemovePrimaryKeyOperation' $SchemaName, $TableName, $Name
}
