function Get-Synonyms
{
    <#
    .SYNOPSIS
    Contains a row for each synonym object that is sys.objects.type = SN.
    #>

    param(
        
    )
    
    Set-StrictMode -Version Latest

    $query = @'
    select * 
    from sys.synonyms
'@
    Invoke-RivetTestQuery -Query $query

}