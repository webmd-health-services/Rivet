
function Get-View
{
    <#
    .SYNOPSIS
    Gets a view.
    #>
    [CmdletBinding()]
    param(
        [string]
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the view.
        $Name
    )
    
    Set-StrictMode -Version Latest

    Get-SysObject @PSBoundParameters -Type 'V'
}
