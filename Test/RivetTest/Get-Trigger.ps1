
function Get-Trigger
{
    <#
    .SYNOPSIS
    Gets trigger for specified name, with a type of TR or TA.  Contains Trigger Definition
    #>

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

    Get-SysObject @PSBoundParameters -Type 'TR'
}
