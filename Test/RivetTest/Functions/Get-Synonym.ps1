
function Get-Synonym
{
    <#
    .SYNOPSIS
    Gets a synonym.
    #>
    param(
        # The name of the synonym.
        [Parameter(Mandatory)]
        [String] $Name,

        # The synonym's schema.
        [String] $SchemaName = 'dbo',

        [String] $DatabaseName
    )

    Set-StrictMode -Version Latest

    $query = @'
    select
        sc.name, sy.*
    from
        sys.synonyms sy join
        sys.schemas sc on sy.schema_id = sc.schema_id
    where
        sc.name = '{0}' and
        sy.name = '{1}'
'@ -f $SchemaName,$Name

    Invoke-RivetTestQuery -Query $query -DatabaseName $DatabaseName

}
