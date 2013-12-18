
function Assert-Row
{
    <#
    .SYNOPSIS
    Asserts that a row exists and that it contains specific column values.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The schema of the table being checked.  Default is `dbo`.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true)]
        [string]
        # The table to read the row from.
        $TableName,

        [Parameter(Mandatory=$true)]
        [string]
        # The filter to use to select one row.
        $Where,

        [Hashtable]
        # Asserts the values of the row.
        $Column
    )
    
    Set-StrictMode -Version Latest

    $row = Get-Row -SchemaName $SchemaName -TableName $TableName -Where $Where
    Assert-NotNull $row

    $Column.Keys | ForEach-Object {
        Assert-Equal $row.$_ $Column.$_
    }
}
