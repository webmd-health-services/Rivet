
function Rename-Object
{
    <#
    .SYNOPSIS
    Renames objects (e.g. tables, constraints, keys).
    
    .DESCRIPTION
    This function wraps the `sp_rename` stored procedure, and can be used to rename objects tracked in `sys.objects`:

     * Tables
     * Functions
     * Synonyms
     * Constraints/keys
     * Views
     * Stored procedures
     * Triggers

    Use `Rename-Index` to rename an index.  Use `Rename-Column` to rename a column.  Use `Rename-DataType` to rename a data type.

    .LINK
    http://technet.microsoft.com/en-us/library/ms188351.aspx

    .LINK
    Rename-Column
    
    .LINK
    Rename-DataType
    
    .LINK
    Rename-Index

    .EXAMPLE
    Rename-Object -Name 'FooBar' -NewName 'BarFoo'
    
    Changes the name of the `FooBar` table to `BarFoo`.
    
    .EXAMPLE
    Rename-Object -SchemaName 'fizz' -Name 'Buzz' -NewName 'Baz'
    
    Demonstrates how to rename a table that is in a schema other than `dbo`.
    
    .EXAMPLE
    Rename-Object 'FK_Foo_Bar' 'FK_Bar_Foo'
    
    Demonstrates how to use `Rename-Object` without explicit parameters, and how to rename a foreign key.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        # The schema of the table.  Default is `dbo`.
        $SchemaName = "dbo",

        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The current name of the table.
        $Name,
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The new name of the table.
        $NewName
    )

    Set-StrictMode -Version 'Latest'

    Write-Verbose (' {0}.{1} -> {0}.{2}' -f $SchemaName,$Name,$NewName)
    New-Object 'Rivet.Operations.RenameOperation' $SchemaName, $Name, $NewName, 'OBJECT'
}
