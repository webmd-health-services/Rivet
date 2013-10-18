
function Get-SysObjects
{
    <#
    .SYNOPSIS
    Contains a row for each user-defined, schema-scoped object that is created within a database.
    #>

    param(
        
    )
    
    Set-StrictMode -Version Latest

    $query = @'
    select * 
    from sys.objects
'@
    Invoke-RivetTestQuery -Query $query

}