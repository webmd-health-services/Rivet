
function Get-ExtendedProperty
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $SchemaName = 'dbo',

        [string]
        $TableName = 'NULL',

        [string]
        $ColumnName = 'NULL',

        [string]
        $ViewName = 'NULL',

        [string]
        $Name = 'NULL'
    )

    $l1Type = 'NULL'
    $l1Name = 'NULL'
    $l2Type = 'NULL'
    $l2Name = 'NULL'

    if( $PSBoundParameters.ContainsKey( 'TableName' ) )
    {
        $l1Type = "'table'"
        $l1Name = "'{0}'" -f $TableName
    }

    if( $PSBoundParameters.ContainsKey( 'TableName' ) )
    {
        $l1Type = "'view'"
        $l1Name = "'{0}'" -f $ViewName
    }

    if( $PSBoundParameters.ContainsKey( 'ColumnName' ) )
    {
        $l2Type = "'column'"
        $l2Name = "'{0}'" -f $ColumnName
    }

    if( $PSBoundParameters.ContainsKey( 'Name' ) )
    {
        $Name = "'{0}'" -f $Name
    }
    
    $query = 'select * from sys.fn_listextendedproperty({0}, ''schema'', ''{1}'', {2}, {3}, {4}, {5})' -f 
                $Name,$SchemaName,$l1Type,$l1Name,$l2Type,$l2Name
    Invoke-RivetTestQuery -Query $query
}