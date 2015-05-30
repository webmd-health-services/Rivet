function Remove-CheckConstraint
{
    <#
    .SYNOPSIS
    Drops a check constraint from a table.
    
    .DESCRIPTION
    Check constraints add validation for data in columns.  This removes those constraints.
    
    .EXAMPLE
    Remove-CheckConstraint 'Migrations' 'CK_Migrations_MigrationID'
    
    Demonstrates how to remove a check constraint from a table.
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
        # The name of the check constraint.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    New-Object 'Rivet.Operations.RemoveCheckConstraintOperation' $SchemaName, $TableName, $Name
}