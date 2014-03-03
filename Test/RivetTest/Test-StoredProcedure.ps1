
function Test-StoredProcedure
{
    <#
    .SYNOPSIS
    Tests if a stored procedure exists.
    #>
    [CmdletBinding()]
    param(
        [string]
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the object.
        $Name
    )
    
    Set-StrictMode -Version Latest

    return ((Get-StoredProcedure @PSBoundParameters) -ne $null)
}
