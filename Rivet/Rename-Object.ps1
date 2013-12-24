
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

    Use `Rename-Index` to rename an index.  Use `Rename-Column` to rename a column.

    .LINK
    Rename-Index

    .LINK
    Rename-Column
    
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
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The current name of the table.
        $Name,
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The new name of the table.
        $NewName,
        
        [Parameter()]
        [string]
        # The schema of the table.  Default is `dbo`.
        $SchemaName = "dbo"
    )

    $op = New-Object 'Rivet.Operations.RenameOperation' $SchemaName, $Name, $NewName
    Write-Host (' {0}.{1} -> {0}.{2}' -f $SchemaName,$Name,$NewName)
    [int]$result = Invoke-MigrationOperation -Operation $op -AsScalar
    
    if ($result -ne 0)
    {
        throw ("Failed to rename {0}.{1} to {0}.{2}: error code {3}" -f $SchemaName,$Name,$NewName,$result)
    }

}
