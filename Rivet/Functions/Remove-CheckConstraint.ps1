function Remove-CheckConstraint
{
    <#
    .SYNOPSIS
    Removes a check constraint from a table.
    
    .DESCRIPTION
    The `Remove-CheckConstraint` operation removes a check constraint from a table. Check constraints add validation for data in columns.
    
    .EXAMPLE
    Remove-CheckConstraint 'Migrations' 'CK_Migrations_MigrationID'
    
    Demonstrates how to remove a check constraint from a table. In this case, the `CK_Migrations_MigrationID` constraint will be removed from the `Migrations` table.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the check constraint's table.
        $TableName,
        
        [Parameter()]
        [string]
        # The schema of the table.  Default is `dbo`.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The name of the check constraint to remove.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    New-Object 'Rivet.Operations.RemoveCheckConstraintOperation' $SchemaName, $TableName, $Name
}