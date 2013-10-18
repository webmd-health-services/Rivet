function Get-Trigger
{
    <#
    .SYNOPSIS
    Gets trigger for specified name, with a type of TR or TA.  Contains Trigger Definition
    #>

    param(

        [Parameter()]
        [string]
        #Name of the Trigger
        $TriggerName

    )
    
    Set-StrictMode -Version Latest

    $query = @'
    select object_definition(object_id)
    from sys.triggers
    where name ='{0}'
'@ -f $TriggerName

    Invoke-RivetTestQuery -Query $query

}