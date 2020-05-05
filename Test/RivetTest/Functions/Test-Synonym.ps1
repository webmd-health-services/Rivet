
function Test-Synonym
{
    <#
    .SYNOPSIS
    Tests if a synonym exists.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the synonym.
        $Name,

        [string]
        # The synonym's schema.
        $SchemaName = 'dbo'
    )
    
    Set-StrictMode -Version Latest

    return ((Get-Synonym @PSBoundParameters) -ne $null)
}
