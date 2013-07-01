
function Remove-Column
{
    <#
    .SYNOPSIS
    Removes a column from a table.

    .DESCRIPTION
    You can't get any of the data back, so be careful.

    .EXAMPLE
    Remove-Column -Name 'CreatedAt' -TableName 'IronManSuits'

    Removes the `CreatedAt` column from the `IronManSuits` table.
    #>
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the column to add.
        $Name,

        # The name of the table where the column should be removed.
        [Parameter(Mandatory=$true)]
        [string]
        $TableName,

        [Alias('TableSchema')]
        [string]
        # The schema of the table where the column should be added.  Default is `dbo`.
        $SchemaName = 'dbo'
    )

    $query = 'alter table [{0}].[{1}] drop column [{2}]' -f $SchemaName,$TableName,$Name
    Write-Host (' {0}.{1} -[{2}]' -f $SchemaName,$TableName,$Name)
    Invoke-Query $query
}
