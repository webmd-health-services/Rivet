function Remove-Trigger
{
    <#
    .SYNOPSIS
    Deletes a new trigger.
    
    .DESCRIPTION
    Deletes an existing trigger.
    
    .LINK
    New-Trigger.
    
    .EXAMPLE
    Remove-Trigger 'PrintMessage' 
    
    Removes the `PrintMessage` trigger.
    #>

    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the trigger.
        $Name,
        
        [Parameter()]
        [string]
        # The schema of the trigger.
        $SchemaName
    )

    $op = New-Object 'Rivet.Operations.RemoveTriggerOperation' $SchemaName, $Name
    Invoke-MigrationOperation -Operation $op
        
}