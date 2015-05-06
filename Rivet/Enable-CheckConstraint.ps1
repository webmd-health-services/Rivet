function Enable-CheckConstraint
{
    <#
    .SYNOPSIS
    Enable a check constraint on a table that has been previously disabled.
    
    .DESCRIPTION
    Enabling check constraints reapplies validation for data in columns.
    
    .EXAMPLE
    
    ...


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

    $op = New-Object 'Rivet.Operations.EnableCheckConstraintOperation' $SchemaName, $TableName, $Name
        
    Write-Host (' {0}.{1} +{2}' -f $SchemaName, $TableName, $Name)
    Invoke-MigrationOperation -Operation $op
}