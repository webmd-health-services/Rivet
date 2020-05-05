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
        [Parameter(Mandatory,Position=0)]
        # The name of the table.
        [String]$Name,

        # The table's schema.  Defaults to `dbo`.
        [String]$SchemaName = 'dbo',

        [Alias('Add')]
        # A script block that returns the new columns to add to a table.
        [scriptblock]$AddColumn,
        
        [Alias('Update')]
        [Alias('Alter')]
        # A script block that returns new column definitions for existing columns
        [scriptblock]$UpdateColumn,

        [Alias('Remove')]
        # Columns to remove.
        [String[]]$RemoveColumn
    )

    Set-StrictMode -Version 'Latest'

    [Object[]]$newColumns = @()
    if( $AddColumn )
    {
        $newColumns = & $AddColumn
    }

    [Object[]]$updatedColumns = @()
    if ($UpdateColumn)
    {
        $updatedColumns = & $UpdateColumn
        foreach( $column in $updatedColumns )
        {
            if( $column.DefaultExpression -or $column.DefaultConstraintName )
            {
                Write-Error -Message ("You're attempting to add a default constraint to existing column [$($column.Name)] on table [$($SchemaName)].[$($Name)]. SQL Server doesn't support adding default constraints on existing columns. Remove the -Default and -DefaultConstraintName parameters on this column and use the Add-DefaultConstraint operation to add a default constraint to this column.") -ErrorAction Stop
                return
            }

            if( $column.Identity )
            {
                Write-Error -Message ("You're attempting to add identity to existing column [$($Column.Name)] on table [$($SchemaName)].[$($Name)]. This is not supported by SQL Server. You'll need to drop and re-create the column.") -ErrorAction Stop
                return
            }
        }

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