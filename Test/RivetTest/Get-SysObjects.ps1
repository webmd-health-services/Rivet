
function Get-SysObject
{
    <#
    .SYNOPSIS
    Gets an object's records from the sys.objects table.
    #>

    param(
        [string]
        # The name of the object.
        $Name,

        [string]
        # The type of the object.
        $Type
    )
    
    Set-StrictMode -Version Latest

    $query = @'
    select 
            o.*, ex.value MS_Description 
        from 
            sys.objects o left outer join
            sys.extended_properties ex on ex.major_id = o.object_id and minor_id = 0 and OBJECTPROPERTY(o.object_id, 'IsMsShipped') = 0 and ex.name = 'MS_Description' 
'@
    $whereClauses = @()
    if( $PSBoundParameters.ContainsKey('Name') )
    {
        $whereClauses += 'o.name = ''{0}''' -f $Name
    }

    if( $PSBoundParameters.ContainsKey('Type') )
    {
        $whereClauses += 'o.type = ''{0}''' -f $Type
    }

    if( $whereClauses )
    {
        $query = @'
{0}
        where
            {1}
'@ -f $query,($whereClauses -join " and`n            ")
        
    }

    Invoke-RivetTestQuery -Query $query

}

Set-Alias -Name 'Get-SysObjects' -Value 'Get-SysObject'