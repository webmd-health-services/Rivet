function Get-Synonym
{
    <#
    .SYNOPSIS
    Contains a row for each synonym object that is sys.objects.type = SN.
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

    Invoke-RivetTestQuery -Query $query

}