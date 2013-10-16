function Get-ObjectDefinition
{
    <#
    .SYNOPSIS
    Returns the Transact-SQL source text of the definition of a specified object.
    #>

    param(

    [Parameter(Mandatory=$true)]
    [Int]
    # The name of the stored procedure.
    $ObjectID

    )
    
    Set-StrictMode -Version Latest

    $query = 'select object_definition ( {0} ) AS [Object Definition]' -f $ObjectID
    Invoke-RivetTestQuery -Query $query

}