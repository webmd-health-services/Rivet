
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
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the target table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the target table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string[]]
        # The column(s) on which the index is based
        $ColumnName  
    )

    Set-StrictMode -Version Latest

    ## Construct Index name

    $indexname = New-ConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName -Index


    $query = 'drop index {0} on {1}.{2}' -f $indexname, $SchemaName, $TableName

    Write-Host (' {0}.{1} -{2}' -f $SchemaName,$TableName,$indexname)

    $op = New-Object 'Rivet.Operations.RawQueryOperation' $query
    Invoke-MigrationOperation -Operation $op
}
