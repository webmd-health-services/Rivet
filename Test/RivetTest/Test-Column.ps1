
function Test-Column
{
    <#
    .SYNOPSIS
    Tests if column exists on a table.

    .DESCRIPTION
    Returns `True` if the column exists, `False` otherwise.

    .EXAMPLE
    Test-Column -Name 'CreatedAt' -TableName 'Customers'

    REturns `True` if the `Customers` table contains a `CreatedAt` column.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the column.
        $Name,

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table.
        $TableName,

        [Alias('TableSchema')]
        [string]
        # The name of the table's schema. Default is `dbo`.
        $SchemaName = 'dbo'
    )

    $column = Get-Column @PSBoundParameters
    return ($column -ne $null)
}
