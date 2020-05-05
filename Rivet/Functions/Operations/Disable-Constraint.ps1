
function Disable-Constraint
{
    <#
    .SYNOPSIS
    Disable a check of foreign key constraint on a table.
    
    .DESCRIPTION
    The `Disable-Constraint` operation disables a check or foreign key constraint on a table. Only check and foreign key constraints can be enabled/disabled.
    
    .LINK
    Enable-Constraint

    .EXAMPLE
    Disable-CheckConstraint 'Migrations' 'CK_Migrations_MigrationID'
    
    Demonstrates how to disable a constraint on a table. In this case, the `CK_Migrations_MigrationID` constraint on the `Migrations` table is disabled. Is it a check constraint? Foreign key constraint? It doesn't matter!
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the constraint's table.
        $TableName,
        
        [Parameter()]
        [string]
        # The schema of the table.  Default is `dbo`.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The name of the constraint.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    New-Object 'Rivet.Operations.DisableConstraintOperation' $SchemaName, $TableName, $Name
}

Set-Alias -Name 'Disable-CheckConstraint' -Value 'Disable-Constraint'
