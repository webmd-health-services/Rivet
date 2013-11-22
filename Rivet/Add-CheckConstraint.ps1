function Add-CheckConstraint
{
    <#
    .SYNOPSIS
    Add a check constraint to a table.
    
    .DESCRIPTION
    Check constraints add validation for data in columns.
    
    .EXAMPLE
    Add-CheckConstraint 'Migrations' 'CK_Migrations_MigrationID' 'MigrationID > 0'
    
    Demonstrates how to add a check constraint to a column that requires the value to be greater than 0.
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
        $Name,
        
        [Parameter(Mandatory=$true,Position=2)]
        [string]
        # The expression to use for the constraint.
        $Expression,
        
        [Switch]
        # Don't use the check constraint when inserting, updating, or deleting rows during replication.
        $NotForReplication,

        [Switch]
        # Don't show any host output.
        $Quiet
    )

    Set-StrictMode -Version 'Latest'

    $op = New-Object 'Rivet.Operations.AddCheckConstraintOperation' $SchemaName, $TableName, $Name, $Expression, $NotForReplication
    if( -not $Quiet )
    {
        Write-Host (' {0}.{1} +{2} {3}' -f $SchemaName, $TableName, $Name, $Expression)
    }
    Invoke-MigrationOperation -Operation $op
}