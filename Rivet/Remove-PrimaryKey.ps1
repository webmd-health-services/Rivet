
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

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string[]]
        # The column(s) that should be part of the primary key.
        $ColumnName,

        [Parameter()]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name
    )

    Set-StrictMode -Version Latest

    $columns = $ColumnName -join ','

    if ($PSBoundParameters.containskey("Name"))
    {
        $op = New-Object 'Rivet.Operations.RemovePrimaryKeyOperation' $SchemaName, $TableName, $ColumnName, $Name
    }
    else 
    {
        $op = New-Object 'Rivet.Operations.RemovePrimaryKeyOperation' $SchemaName, $TableName, $ColumnName
    }

    Write-Host (' {0}.{1} -{2} ({3})' -f $SchemaName,$TableName,$op.ConstraintName.Name,$columns)
    Invoke-MigrationOperation -Operation $op
}
