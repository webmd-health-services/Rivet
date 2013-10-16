function Add-Trigger
{
    <#
    .SYNOPSIS
    Creates a new trigger.
    
    .DESCRIPTION
    Creates a new trigger.  If updating an existing trigger, use `Remove-Trigger` to remove it first, then `New-Trigger` to re-create it.
    
    .LINK
    Remove-Trigger.
    
    .EXAMPLE
    Add-Trigger 'PrintMessage' 'ON rivet.Migrations for insert as print ''Migration applied!'''
    
    Creates a trigger that prints a method when a row gets inserted into the `rivet.Migrations` table.
    #>
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the trigger.
        $Name,
        
        [Parameter()]
        [string]
        # The schema of the trigger.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The body of the trigger.  Everything after the `ON` clause.
        $Definition
    )

    $op = New-Object 'Rivet.Operations.AddTriggerOperation' $SchemaName, $Name, $Definition
    Write-Host(' +[{0}].[{1}]' -f $SchemaName,$Name)
    Invoke-MigrationOperation -operation $op
        
}