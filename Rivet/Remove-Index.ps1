
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
        $Column  
    )

    Set-StrictMode -Version Latest

    ## Construct Index name

    $indexname = Join-String "IX_",$TableName

    ## Construct Comma Separated List of Columns

    $ColumnString = [string]::join(',', $Column)

$query = @'
    drop index {0}
    on {1}.{2}

'@ -f $indexname, $SchemaName, $TableName

    Write-Host $query

    Invoke-Query -Query $query
}
