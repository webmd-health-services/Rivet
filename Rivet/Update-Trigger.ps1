
function Update-Trigger
{
    <#
    .SYNOPSIS
    Updates an existing trigger.
    
    .DESCRIPTION
    Updates an existing trigger.

    .LINK
    https://msdn.microsoft.com/en-us/library/ms176072.aspx
    
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
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The body of the trigger.  Everything after and including the `ON` clause.
        $Definition
    )

    Set-StrictMode -Version 'Latest'

    Write-Verbose (' ={0}.{1}' -f $SchemaName,$Name)
    New-Object 'Rivet.Operations.UpdateTriggerOperation' $SchemaName, $Name, $Definition
}
