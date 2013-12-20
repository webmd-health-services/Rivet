
function Rename-Object
{
    <#
    .SYNOPSIS
    Renames an objects.
    
    .DESCRIPTION
    SQL Server ships with a stored procedure which is used to rename certain objects.  This operation wraps that stored procedure.
    
    .EXAMPLE
    Rename-Object -Name 'FooBar' -NewName 'BarFoo'
    
    Changes the name of the `FooBar` table to `BarFoo`.
    
    .EXAMPLE
    Rename-Object -SchemaName 'fizz' -Name 'Buzz' -NewName 'Baz'
    
    Demonstrates how to rename a table that is in a schema other than `dbo`.
    
    .EXAMPLE
    Rename-Object 'FooBar' 'BarFoo'
    
    Demonstrates how to use the short form to rename `FooBar` to `BarFoo`.
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