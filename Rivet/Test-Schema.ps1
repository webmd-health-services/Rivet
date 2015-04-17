
function Test-Schema
{
    <#
    .SYNOPSIS
    Tests if a schema exists.

    .EXAMPLE
    Test-Schema -Name 'rivet'

    Returns `$true` if the `rivet` schema exists.  Otherwise, returns `$false`.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the schema.
        $Name
    )

    $query = 'select count(*) from sys.schemas where name = ''{0}''' -f $Name
    $schemaCount = Invoke-Query -Query $query -AsScalar

    return ( $schemaCount -gt 0 )


}