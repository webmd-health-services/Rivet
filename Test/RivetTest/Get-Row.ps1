function Get-Row
{
    param(
        $TableName,

        [string]
        $SchemaName = 'dbo'

    )
    
    Set-StrictMode -Version Latest

    $table = Get-Table -Name $TableName -SchemaName $SchemaName
    Assert-NotNull $table ('table {0} not found' -f $TableName) 

    $query = "select * from [{0}]" -f $TableName
    Invoke-RivetTestQuery -Query $query -Connection $RTDatabaseConnection

}
