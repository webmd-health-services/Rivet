function Rename-Constraint
{
    <#
    .SYNOPSIS
    Renames constraints: primary keys, foreign keys, check constraints, or unique constraints.
    
    .DESCRIPTION
    SQL Server ships with a stored procedure which is used to rename certain objects.  This operation wraps that stored procedure for renaming table constraints.
    
    .EXAMPLE
    Rename-Constraint  -Name 'Fizz' -NewName 'PK_Fizz'
    
    Changes the name of the `Fizz` constraint on the `FooBar` table to `PK_Fizz`.
    
    .EXAMPLE
    Rename-Constraint -Name 'Fizz' -NewName 'PK_Fizz'
    
    Demonstrates how to rename a constraint on a table that is in a schema other than `dbo`.
    
    .EXAMPLE
    Rename-Constraint 'FizzPK' 'PK_Fizz'
    
    Demonstrates how to use the short form to rename the `Fizz` constraint on the `FooBar` table to `PK_Fizz`: table name is first, then existing constraint name, then new constraint name.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The current name of the constraint.
        $Name,
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The new name of the constraint.
        $NewName,
        
        [string]
        # The schema of the table.  Default is `dbo`.
        $SchemaName = 'dbo'
    )

    $op = New-Object 'Rivet.Operations.RenameOperation' $SchemaName, $Name, $NewName
    Write-Host (' {0}.{1} -> {0}.{2}' -f $SchemaName,$Name,$NewName)
    $result = Invoke-MigrationOperation -Operation $op -AsScalar
    
    if ($result -ne 0)
    {
        throw ("Failed to rename {0}.{1} to {0}.{2}: error code {3}" -f $SchemaName,$Name,$NewName,$result)
    }
}