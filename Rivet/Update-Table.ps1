function Update-Table
{
    <#
    .SYNOPSIS
    Adds new columns or alters existing columns on an existing table.

    .DESCRIPTION
    The `Update-Table` operation adds, updates, and removes columns from a table. Columns are added, then updated, then removed.
    
    The new columns for the table should be created and returned in a script block, which is passed as the value of the `AddColumn` parameter.  For example,

        Update-Table 'Suits' -AddColumn {
            Bit 'HasVest' -NotNull -Default 0
        }
        
    The new definitions for existing columns should be created and returned in a script block, which is passed as the value of the `UpdateColumn` parameter.  For example,
    
        Update-Table 'Suits' -UpdateColumn {
            VarChar 'Color' 256 -NotNull
        }

    .LINK
    bigint

    .LINK
    binary

    .LINK
    bit

    .LINK
    char

    .LINK
    date

    .LINK
    datetime

    .LINK
    datetime2

    .LINK
    datetimeoffset

    .LINK
    decimal

    .LINK
    float

    .LINK
    hierarchyid

    .LINK
    int

    .LINK
    money

    .LINK
    nchar

    .LINK
    numeric

    .LINK
    nvarchar

    .LINK
    real

    .LINK
    rowversion

    .LINK
    smalldatetime

    .LINK
    smallint

    .LINK
    smallmoney

    .LINK
    sqlvariant

    .LINK
    time

    .LINK
    tinyint

    .LINK
    uniqueidentifier

    .LINK
    varbinary

    .LINK
    varchar

    .LINK
    xml

    .EXAMPLE
    Update-Table -Name 'Ties' -AddColumn { VarChar 'Color' 50 -NotNull }

    Adds a new `Color` column to the `Ties` table.  Pretty!
    
    .EXAMPLE
    Update-Table -Name 'Ties' -UpdateColumn { VarChar 'Color' 100 -NotNull }
    
    Demonstrates how to change the definition of an existing column.

    .EXAMPLE
    Update-Table -Name 'Ties' -RemoveColumn 'Pattern','Manufacturer'

    Demonstrates how to remove columns from a table.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the table.
        $Name,

        [string]
        # The table's schema.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Alias('Add')]
        [ScriptBlock]
        # A script block that returns the new columns to add to a table.
        $AddColumn,
        
        [Alias('Update')]
        [Alias('Alter')]
        [ScriptBlock]
        # A script block that returns new column definitions for existing columns
        $UpdateColumn,

        [Alias('Remove')]
        [string[]]
        # Columns to remove.
        $RemoveColumn
    )

    Set-StrictMode -Version 'Latest'

    $newColumns = @()
    if ($AddColumn)
    {
        [Object[]]$newColumns = & $AddColumn
    }
    
    $updatedColumns = @()
    if ($UpdateColumn)
    {
        [Object[]]$updatedColumns = & $UpdateColumn
    }

    New-Object 'Rivet.Operations.UpdateTableOperation' $SchemaName,$Name,$newColumns,$updatedColumns,$RemoveColumn

    foreach ($i in $newColumns)
    {
        if ($i.Description)
        {
            Add-Description -Description $i.Description -SchemaName $SchemaName -TableName $Name -ColumnName $i.Name
        }
    }

    foreach ($i in $updatedColumns)
    {
        if ($i.Description)
        {
            Update-Description -Description $i.Description -SchemaName $SchemaName -TableName $Name -ColumnName $i.Name
        }
    }
}