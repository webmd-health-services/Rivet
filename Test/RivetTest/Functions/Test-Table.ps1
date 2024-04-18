
function Test-Table
{
    param(
        [Parameter(Mandatory)]
        [String] $Name,

        # The schema name of the table.  Defaults to `dbo`.
        [String] $SchemaName = 'dbo',

        [String] $DatabaseName
    )

    return Test-DatabaseObject -Table -Name $Name -SchemaName $SchemaName -DatabaseName $DatabaseName
}
