
function Get-Index
{
    <#
    .SYNOPSIS
    Contains a row per index or heap of a tabular object, such as a table, view, or table-valued function.
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table whose primary key to get.
        $TableName
    )
    
    Set-StrictMode -Version Latest

    $query = @'
    select * 
    from sys.indexes
    where object_id = OBJECT_ID('{0}') and index_id > 0 and type in (1,2)
'@ -f $TableName
    
    Invoke-RivetTestQuery -Query $query

}