
function Test-UniqueKey
{
    <#
    .SYNOPSIS
    Tests that a unique key exists on the given columns in a table.
    #>
    [CmdletBinding()]
    param(
        [string]
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table whose primary key to get.
        $TableName,

        [Parameter(Mandatory=$true)]
        [string[]]
        # Columns that are part of the key.
        $ColumnName
    )
    
    Set-StrictMode -Version Latest

    return ((Get-UniqueKey @PSBoundParameters) -ne $null)
}
