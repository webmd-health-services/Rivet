
function Get-StoredProcedure
{
    <#
    .SYNOPSIS
    Gets a stored procedure.
    #>
    [CmdletBinding()]
    param(
        [string]
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the stored procedure.
        $Name
    )
    
    Set-StrictMode -Version Latest

    Get-SysObject @PSBoundParameters -Type 'P'
}
