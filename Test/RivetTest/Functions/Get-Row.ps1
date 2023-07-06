
function Get-Row
{
    param(
        [string]
        $SchemaName = 'dbo',

        [string]
        $TableName,

        [string]
        $Where
    )

    Set-StrictMode -Version Latest

    $table = Get-Table -Name $TableName -SchemaName $SchemaName

    $table | Should -Not -BeNullOrEmpty ('table {0} not found' -f $TableName)

    $whereClause = ''
    if( $PSBoundParameters.ContainsKey('Where') )
    {
        $whereClause = ' where {0}' -f $Where
    }
    $query = "select * from [{0}].[{1}]{2}" -f $SchemaName,$TableName,$whereClause

    Invoke-RivetTestQuery -Query $query

}
