function Disable-CheckConstraint
{
    <#
    .SYNOPSIS
    Disable a check constraint on a table.
    
    .DESCRIPTION
    Disabling check constraints removes validation for data in columns.
    
    .EXAMPLE
    Disable-CheckConstraint 'Migrations' 'CK_Migrations_MigrationID'
    
    Disables the check constraint named 'CK_Migrations_MigrationID' on the 'Migrations' table.
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

    Write-Verbose (' {0}.{1} -{2}' -f $SchemaName, $TableName, $Name)
    New-Object 'Rivet.Operations.DisableCheckConstraintOperation' $SchemaName, $TableName, $Name
}