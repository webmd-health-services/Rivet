
function Get-IndexColumns
{
    <#
    .SYNOPSIS
    Contains one row per column that is part of a sys.indexes index or unordered table (heap).
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
    from sys.index_columns
    where object_id = OBJECT_ID('{0}')
'@ -f $TableName
    
    Invoke-RivetTestQuery -Query $query

}