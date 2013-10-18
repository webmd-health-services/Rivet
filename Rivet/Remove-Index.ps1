
function Remove-Index
{
    <#
    .SYNOPSIS
    Removes one relational index from the database

    .DESCRIPTION
    Removes one relational index from the database.

    .LINK
    Remove-Index

    .EXAMPLE
    Remove-Index -TableName Cars -Column Year

    Drops a relational index of column 'Year' on the table 'Cars'

    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the target table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the target table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1)]
        [string[]]
        # The column(s) on which the index is based
        $ColumnName  
    )

    Set-StrictMode -Version Latest

    $op = New-Object 'Rivet.Operations.RemoveIndexOperation' $SchemaName, $TableName, $ColumnName
    Write-Host (' {0}.{1} -{2}' -f $SchemaName,$TableName,$op.ConstraintName.Name)
    Invoke-MigrationOperation -Operation $op
}
