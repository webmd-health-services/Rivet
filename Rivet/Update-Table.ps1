function Update-Table
{
    <#
    .SYNOPSIS
    Adds new columns or alters existing columns on an existing table.

    .DESCRIPTION
    The new columns for the table should be created and returned in a script block, which is passed as the value of the `AddColumn` parameter.  For example,

        Update-Table 'Suits' -AddColumn {
            Bit 'HasVest' -NotNull -Default 0
        }
        
    The new definitions for existing columns should be created and returned in a script block, which is passed as the value of the `UpdateColumn` parameter.  For example,
    
        Update-Table 'Suits' -UpdateColumn {
            VarChar 'Color' 256 -NotNull
        }

    .EXAMPLE
    Update-Table -Name 'Ties' -AddColumn { VarChar 'Color' 50 -NotNull }

    Adds a new `Color` column to the `Ties` table.  Pretty!
    
    .EXAMPLE
    Update-Table -Name 'Ties' -UpdateColumn { VarChar 'Color' 100 -NotNull }
    
    Demonstrates how to change the definition of an existing column.
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
        $UpdateColumn
    )

    if ($AddColumn){
        $Add = @(& $AddColumn)
    }
    
    if ($UpdateColumn){
        $Update = @(& $UpdateColumn)
    }

    foreach ($i in $Add)
    {
        Write-Host (' {0}.{1} +{2}' -f $SchemaName,$Name,$i.GetColumnDefinition($TableName,$SchemaName,$false))
    }

    foreach ($i in $Update)
    {
        Write-Host (' {0}.{1} ={2}' -f $SchemaName,$Name,$i.GetColumnDefinition($TableName,$SchemaName,$false))
    }


    $op = New-Object 'Rivet.Operations.UpdateTableOperation' $SchemaName,$Name,$Add,$Update
    Invoke-MigrationOperation -Operation $op

    foreach ($i in $Add)
    {
        if ($i.Description)
        {
            Add-Description -Description $i.Description -SchemaName $SchemaName -TableName $Name -ColumnName $i.Name -Quiet
        }
    }

    foreach ($i in $Update)
    {
        if ($i.Description)
        {
            Update-Description -Description $i.Description -SchemaName $SchemaName -TableName $Name -ColumnName $i.Name -Quiet
        }
    }
}