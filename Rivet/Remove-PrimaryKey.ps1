
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
    Remove-PrimaryKey -TableName Cars -ColumnName Year,Make,Model

    Removes a primary key to the `Cars` table on the `Year`, `Make`, and `Model` columns.

    .EXAMPLE
    Remove-PrimaryKey 'Cars' -Name 'Car_PK'

    Demonstrates how to remove a primary key whose name is different than the derived name Rivet creates for primary keys.
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
        [string[]]
        # The column(s) that should be part of the primary key.
        $ColumnName,

        [Parameter(Mandatory=$true,ParameterSetName='ByCustomName')]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    if ($PSBoundParameters.containskey("Name"))
    {
        $op = New-Object 'Rivet.Operations.RemovePrimaryKeyOperation' $SchemaName, $TableName, $Name
        Write-Host (' {0}.{1} -{2}' -f $SchemaName,$TableName,$op.Name)
    }
    else 
    {
        $columns = $ColumnName -join ','
        $op = New-Object 'Rivet.Operations.RemovePrimaryKeyOperation' $SchemaName, $TableName, $ColumnName
        Write-Host (' {0}.{1} -{2} ({3})' -f $SchemaName,$TableName,$op.Name,$columns)
    }

    Invoke-MigrationOperation -Operation $op
}
