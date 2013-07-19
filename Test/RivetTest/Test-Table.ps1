
function Test-Table
{
    param(
        $Name,
        
        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo'
    )
    return Test-DatabaseObject -Table -Name $Name -SchemaName $SchemaName
}
