
function Get-KeyConstraint
{
    <#
    .SYNOPSIS
    Contains a row for each object that is a primary key or unique constraint. Includes sys.objects.type PK and UQ.
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table whose primary key to get.
        $TableName,

        [Switch]
        # Only return key constraints of the UNIQUE type
        $ReturnUnique

    )

    $uniqueclause = ''
    if ($ReturnUnique)
    {
        $uniqueclause = "where type = 'UQ'"
    }

    $query = @'
    select * 
    from sys.key_constraints
    {0}
'@ -f $uniqueclause
    
    Invoke-RivetTestQuery -Query $query

}