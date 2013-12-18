
function Test-Trigger
{
    <#
    .SYNOPSIS
    Tests if a trigger exists.
    #>
    [CmdletBinding()]
    param(
        [string]
        # The schema of the trigger.
        $SchemaName = 'dbo',

        [Alias('TriggerName')]
        [Parameter()]
        [string]
        #Name of the Trigger
        $Name
    )
    
    Set-StrictMode -Version Latest

    return ((Get-Trigger @PSBoundParameters) -ne $null)
}
