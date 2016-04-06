
function Remove-RowGuidCol
{
    <#
    .SYNOPSIS
    Remove the `rowguidcol` property from a column in a table.

    .DESCRIPTION
    The `Remove-RowGuidCol` operation removes the `rowguidcol` property from a `uniqueidentifier` column in a table.

    The `Remove-RowGuidCol` operation was added in Rivet 0.7.

    .LINK
    https://msdn.microsoft.com/en-us/library/ms190273.aspx

    .LINK
    Add-RowGuidCol

    .EXAMPLE
    Remove-RowGuidCol -TableName 'MyTable' -ColumnName 'MyUniqueIdentifier'

    Demonstrates how to remove the `rowguidcol` property from a column in a table. In this example, the `dbo.MyTable` table's `MyUniqueIdentifier` column will lose the propery.

    .EXAMPLE
    Remove-RowGuidCol -SchemaName 'cstm' -TableName 'MyTable' -ColumnName 'MyUniqueIdentifier'

    Demonstrates how to remove the `rowguidcol` property from a column in a table whose schema isn't `dbo`, in this case the `cstm.MyTable` table's `MyUniqueIdentifier` column will lose the property.
    #>
    [CmdletBinding()]
    param(
        [string]
        # The table's schema. Default is `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The table's name.
        $TableName,

        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The name of the column that should get the `rowguidcol` property.
        $ColumnName
    )

    Set-StrictMode -Version 'Latest'

    New-Object -TypeName 'Rivet.Operations.RemoveRowGuidColOperation' -ArgumentList $SchemaName,$TableName,$ColumnName
}