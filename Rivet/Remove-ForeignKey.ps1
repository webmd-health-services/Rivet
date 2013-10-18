
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
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The string that references the table
        $References,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $ReferencesSchema = 'dbo'
    )

    Set-StrictMode -Version Latest

    $op = New-Object 'Rivet.Operations.RemoveForeignKeyOperation' $SchemaName, $TableName, $ReferencesSchema, $References
    Write-Host (' {0}.{1} -{2}' -f $SchemaName,$TableName,$op.ForeignKeyConstraintName.Name)
    Invoke-MigrationOperation -Operation $op
}
