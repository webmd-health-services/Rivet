
function Get-IndexColumn
{
    <#
    .SYNOPSIS
    Gets the columns that are part of an index.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $InputObject
    )

    begin
    {
    }

    process
    {
        $query = @'
    select
        c.name column_name, i.*, ic.*, c.*
    from 
        sys.indexes i 
        inner join sys.index_columns ic on ic.index_id = i.index_id and ic.object_id=i.object_id
        inner join sys.columns c on ic.object_id = c.object_id and c.column_id = ic.column_id
    where 
        i.object_id = {0} and i.index_id={1}
    order by
        ic.key_ordinal
'@ -f $InputObject.object_id, $InputObject.index_id
        
        [Object[]]$columns = Invoke-RivetTestQuery -Query $query
        Add-Member -InputObject $InputObject -MemberType NoteProperty -Name 'Columns' -Value $columns -PassThru        
    }

    end
    {
    }

}