
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
        [string]
        # The string that references the table
        $References
    )

    Set-StrictMode -Version Latest

    $name = New-ConstraintName -TableName $TableName -SchemaName $SchemaName -ColumnName $References -ForeignKey

    $query = @'
    ALTER TABLE {0} DROP CONSTRAINT {1}
'@ -f $TableName,$name

    Write-Host (' +{0}.{1} remove foreign key {2} ({3})' -f $SchemaName,$TableName,$name,$References)
    Invoke-Query -Query $query
}
