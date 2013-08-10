
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
        $ColumnName
    )

    Set-StrictMode -Version Latest

    $name = New-ConstraintName -TableName $TableName -SchemaName $SchemaName -ColumnName $ColumnName -PrimaryKey

    $columns = $ColumnName -join ','
    $query = @'
    alter table {0} drop constraint {1}
'@ -f $TableName,$name

    Write-Host (' {0}.{1} -{2} ({3})' -f $SchemaName,$TableName,$name,$columns)
    
    $op = New-Object 'Rivet.Operations.RawQueryOperation' $query
    Invoke-MigrationOperation -Operation $op
}
