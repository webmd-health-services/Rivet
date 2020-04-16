
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
        # The schema of the table.  Default is `dbo`.
        [String]$SchemaName = "dbo",

        [Parameter(Mandatory,Position=0)]
        # The current name of the table.
        [String]$Name,
        
        [Parameter(Mandatory,Position=1)]
        # The new name of the table.
        [String]$NewName
    )

    Set-StrictMode -Version 'Latest'

    [Rivet.Operations.RenameObjectOperation]::New($SchemaName, $Name, $NewName, 'USERDATATYPE')

}
