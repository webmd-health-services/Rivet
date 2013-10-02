function Update-Trigger
{
    <#
    .SYNOPSIS
    Updates an existing trigger.
    
    .DESCRIPTION
    Updates an existing trigger.
    
    .LINK
    Add-Trigger
    Remove-Trigger
    
    .EXAMPLE
    Update-Trigger 'PrintMessage' 'ON rivet.Migrations for insert as print ''Migration applied!'''
    
    Updates a trigger to prints a method when a row gets inserted into the `rivet.Migrations` table.
    #>
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the trigger.
        $Name,
        
        [Parameter()]
        [string]
        # The schema of the trigger.
        $SchemaName,
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The body of the trigger.  Everything after the `ON` clause.
        $Definition
    )

    $op = New-Object 'Rivet.Operations.UpdateTriggerOperation' $SchemaName, $Name, $Definition
    Write-Host(' =[{0}].[{1}]' -f $SchemaName,$Name)
    Invoke-MigrationOperation -operation $op
        
}