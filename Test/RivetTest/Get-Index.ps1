
function Get-Index
{
    <#
    .SYNOPSIS
    Contains a row per index or heap of a tabular object, such as a table, view, or table-valued function.
    #>

    param(
        [Parameter(Mandatory=$true)]
        $Name
    )
    
    Set-StrictMode -Version Latest

    $query = @'
    select * 
    from sys.indexes
    where name = '{0}' and index_id > 0 and type in (1,2)
'@ -f $Name
    
    Invoke-RivetTestQuery -Query $query

}