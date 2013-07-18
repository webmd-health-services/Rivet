
function Add-Schema
{
    <#
    .SYNOPSIS
    Creates a new schema.

    .EXAMPLE
    Add-Schema -Name 'rivetexample'

    Creates the `rivetexample` schema.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [Alias('SchemaName')]
        [string]
        # The name of the schema.
        $Name,

        [Alias('Authorization')]
        [string]
        # The owner of the schema.
        $Owner
    )

    $query = 'create schema [{0}]' -f $Name
    if( $Owner )
    {
        $query = '{0} authorization [{1}]' -f $query,$Owner
    }
    Write-Host (' + {0}' -f $Name)
    Invoke-Query -Query $query 
}