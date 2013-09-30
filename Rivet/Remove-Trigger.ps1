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
        $SchemaName = "dbo"
    )

    $op = New-Object 'Rivet.Operations.RemoveTriggerOperation' $SchemaName, $Name
    Write-Host (' -[{0}].[{1}]' -f $SchemaName,$Name)
    Invoke-MigrationOperation -Operation $op
        
}