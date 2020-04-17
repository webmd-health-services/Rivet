
function Enable-Constraint
{
    <#
    .SYNOPSIS
    Enable a check or foreign key constraint.
    
    .DESCRIPTION
    The `Enable-Constraint` operation enables a check or foreign key constraint on a table. Only check and foreign key constraints can be enabled/disabled.
    
    .LINK
    Disable-Constraint

    .EXAMPLE
    Enable-Constraint 'Migrations' 'FK_Migrations_MigrationID'
    
    Demonstrates how to disable a constraint on a table. In this case, the `FK_Migrations_MigrationID` constraint on the `Migrations` table is disabled. Is it a check constraint? Foreign key constraint? It doesn't matter!
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]
        # The name of the constraint's table.
        [String]$TableName,
        
        [Parameter()]
        # The schema of the table.  Default is `dbo`.
        [String]$SchemaName = 'dbo',
        
        [Parameter(Mandatory,Position=1)]
        # The name of the constraint.
        [String]$Name
    )

    Set-StrictMode -Version 'Latest'

    [Rivet.Operations.EnableConstraintOperation]::New($SchemaName, $TableName, $Name, $false)
}

Set-Alias -Name 'Enable-CheckConstraint' -Value 'Enable-Constraint'
