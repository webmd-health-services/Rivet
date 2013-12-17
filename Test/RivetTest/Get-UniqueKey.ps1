
function Get-UniqueKey
{
    <#
    .SYNOPSIS
    Gets a unique key.
    #>
    [CmdletBinding()]
    param(
        [string]
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table whose primary key to get.
        $TableName
    )
    
    Set-StrictMode -Version Latest

    $query = @'
    select * 
    from sys.key_constraints
    where type='UQ'
    {0}
'@ -f $uniqueclause
    
    Invoke-RivetTestQuery -Query $query

}