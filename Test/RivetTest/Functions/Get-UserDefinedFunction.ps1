
function Get-UserDefinedFunction
{
    <#
    .SYNOPSIS
    Gets a user-defined function.
    #>
    [CmdletBinding()]
    param(
        [string]
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the function.
        $Name
    )
    
    Set-StrictMode -Version Latest

    Get-SysObject @PSBoundParameters -Type 'FN'
}
