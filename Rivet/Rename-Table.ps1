function Rename-Table
{
    <#
    .SYNOPSIS
    Renames a table.
    
    .DESCRIPTION
    SQL Server ships with a stored procedure which is used to rename certain objects.  This operation wraps that stored procedure.
    
    .EXAMPLE
    Rename-Table -Name 'FooBar' -NewName 'BarFoo'
    
    Changes the name of the `FooBar` table to `BarFoo`.
    
    .EXAMPLE
    Rename-Table -SchemaName 'fizz' -Name 'Buzz' -NewName 'Baz'
    
    Demonstrates how to rename a table that is in a schema other than `dbo`.
    
    .EXAMPLE
    Rename-Table 'FooBar' 'BarFoo'
    
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
    $return = Invoke-MigrationOperation -Operation $op -AsScalar
    Write-Host (' ={0}.{1}' -f $SchemaName,$NewName)
    
    if ($return -ne 0)
    {
        throw "sp_rename operation has failed with error code: {0}" -f $return
        return
    }

}