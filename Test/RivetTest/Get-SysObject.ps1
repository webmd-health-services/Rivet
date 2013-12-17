
function Get-SysObject
{
    <#
    .SYNOPSIS
    Gets an object's records from the sys.objects table.
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the object.
        $Name,

        [string]
        $SchemaName = 'dbo',

        [string]
        # The type of the object.
        $Type
    )
    
    Set-StrictMode -Version Latest

    $typeClause = ''
    if( $PSBoundParameters.ContainsKey('Type') )
    {
        $typeClause = " and`n            o.type = '{0}'" -f $Type
    }

    $query = @'
    select 
            s.name schema_name, o.*, ex.value MS_Description, object_definition(o.object_id) definition
        from 
            sys.objects o join
            sys.schemas s on o.schema_id = s.schema_id left outer join
            sys.extended_properties ex on ex.major_id = o.object_id and minor_id = 0 and OBJECTPROPERTY(o.object_id, 'IsMsShipped') = 0 and ex.name = 'MS_Description' 
        where
            s.name = '{0}' and
            o.name = '{1}'{2}
'@ -f $SchemaName,$Name,$typeClause

    Invoke-RivetTestQuery -Query $query

}
