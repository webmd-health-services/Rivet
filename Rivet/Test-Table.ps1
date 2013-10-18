
function Test-Table
{
    <#
    .SYNOPSIS
    Tests if a table exists.

    .DESCRIPTION
    Returns `$true` if a table exists.  `$false` otherwise.

    .OUTPUTS
    System.Boolean.

    .EXAMPLE
    Test-Table -Name Cars

    Returns `$true` if the `Cars` table exists, otherwise returns `$false`.

    .EXAMPLE
    Test-Table -Name Cars -SchemaName pixar

    Demonstrates how to test if a table exists that isn't in the default `dbo` schema.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [Alias('TableName')]
        [string]
        # The name of the table.
        $Name,

        [string]
        # The table's schema.
        $SchemaName
    )

    $query = @'
        select count(*) from sys.tables t inner join 
            sys.schemas s on t.schema_id=s.schema_id 
            where s.name = '{0}' and t.name = '{1}'
'@ -f $SchemaName,$Name
    $tableCount = Invoke-Query -Query $query -AsScalar
    return ( $tableCount -gt 0 )
}
