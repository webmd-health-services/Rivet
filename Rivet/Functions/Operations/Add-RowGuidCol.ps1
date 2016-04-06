
function Add-RowGuidCol
{
    <#
    .SYNOPSIS
    Adds the `rowguidcol` property to a column in a table.

    .DESCRIPTION
    The `Add-RowGuidCol` operation adds the `rowguidcol` property to a `uniqueidentifier` column in a table. A table can only have one `rowguidcol` column. If a table has an existing `rowguidcol` column, use `Remove-RowGuidCol` to remove it before adding a new one.

    The `Add-RowGuidCol` operation was added in Rivet 0.7.

    .LINK
    https://msdn.microsoft.com/en-us/library/ms190273.aspx

    .LINK
    Remove-RowGuidCol

    .EXAMPLE
    Add-RowGuidCol -TableName 'MyTable' -ColumnName 'MyUniqueIdentifier'

    Demonstrates how to add the `rowguidcol` property to a column in a table. In this example, the `dbo.MyTable` table's `MyUniqueIdentifier` column will get the propery.

    .EXAMPLE
    Add-RowGuidCol -SchemaName 'cstm' -TableName 'MyTable' -ColumnName 'MyUniqueIdentifier'

    Demonstrates how to add the `rowguidcol` property to a column in a table whose schema isn't `dbo`, in this case the `cstm.MyTable` table's `MyUniqueIdentifier` column will get the property.
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

    New-Object -TypeName 'Rivet.Operations.AddRowGuidColOperation' -ArgumentList $SchemaName,$TableName,$ColumnName
}