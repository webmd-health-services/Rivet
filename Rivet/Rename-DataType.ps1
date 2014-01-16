
function Rename-DataType
{
    <#
    .SYNOPSIS
    Renames data types.
    
    .DESCRIPTION
    This function wraps the `sp_rename` stored procedure, and can be used to rename `USERDATATYPE` types.

    Use `Rename-Index` to rename an index.  Use `Rename-Column` to rename a column.  Use `Rename-Object` to rename an object.

    .LINK
    http://technet.microsoft.com/en-us/library/ms188351.aspx

    .LINK
    Rename-Column
    
    .LINK
    Rename-Index

    .LINK
    Rename-Object

    .EXAMPLE
    Rename-DataType -Name 'FooBar' -NewName 'BarFoo'
    
    Changes the name of the `FooBar` type to `BarFoo`.
    
    .EXAMPLE
    Rename-DataType -SchemaName 'fizz' -Name 'Buzz' -NewName 'Baz'
    
    Demonstrates how to rename a data type that is in a schema other than `dbo`.
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

    $op = New-Object 'Rivet.Operations.RenameOperation' $SchemaName, $Name, $NewName, 'USERDATATYPE'
    Write-Host (' {0}.{1} -> {0}.{2}' -f $SchemaName,$Name,$NewName)
    [int]$result = Invoke-MigrationOperation -Operation $op -AsScalar
    
    if ($result -ne 0)
    {
        throw ("Failed to rename data type {0}.{1} to {0}.{2}: error code {3}" -f $SchemaName,$Name,$NewName,$result)
    }

}
