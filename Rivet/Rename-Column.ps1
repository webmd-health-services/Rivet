function Rename-Column
{
    <#
    .SYNOPSIS
    Renames a column.
    
    .DESCRIPTION
    SQL Server ships with a stored procedure which is used to rename certain objects.  This operation wraps that stored procedure.
    
    Use `Rename-DataType` to rename a data type.  Use `Rename-Index` to rename an index.  Use `Rename-Object` to rename an object.

    .LINK
    http://technet.microsoft.com/en-us/library/ms188351.aspx

    .LINK
    Rename-DataType

    .LINK
    Rename-Index
    
    .LINK
    Rename-Object
    
    .EXAMPLE
    Rename-Column -TableName 'FooBar' -Name 'Fizz' -NewName 'Buzz'
    
    Changes the name of the `Fizz` column in the `FooBar` table to `Buzz`.
    
    .EXAMPLE
    Rename-Column -SchemaName 'fizz' -TableName 'FooBar' -Name 'Buzz' -NewName 'Baz'
    
    Demonstrates how to rename a column in a table that is in a schema other than `dbo`.
    
    .EXAMPLE
    Rename-Column 'FooBar' 'Fizz' 'Buzz'
    
    Demonstrates how to use the short form to rename `Fizz` column in the `FooBar` table to `Buzz`: table name is first, then existing column name, then new column name.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the table of the column to rename.
        $TableName,
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The current name of the column.
        $Name,
        
        [Parameter(Mandatory=$true,Position=2)]
        [string]
        # The new name of the column.
        $NewName,
        
        [Parameter()]
        [string]
        # The schema of the table.  Default is `dbo`.
        $SchemaName = 'dbo'
    )

    Set-StrictMode -Version 'Latest'

    New-Object 'Rivet.Operations.RenameColumnOperation' $SchemaName, $TableName, $Name, $NewName
}