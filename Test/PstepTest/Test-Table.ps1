
function Test-Table
{
    param(
        $Name,
        
        $SchemaName = 'dbo'
    )
    return Test-DatabaseObject -Table -Name $Name -SchemaName $SchemaName
}
