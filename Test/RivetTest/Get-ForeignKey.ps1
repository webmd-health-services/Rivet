
function Get-ForeignKey
{
    <#
    .SYNOPSIS
    Contains a row per object that is a FOREIGN KEY constraint, with sys.object.type = F.
    #>

    param(
        
    )
    
    Set-StrictMode -Version Latest

    $query = @'
    select * 
    from sys.foreign_keys
'@
    Invoke-RivetTestQuery -Query $query

}