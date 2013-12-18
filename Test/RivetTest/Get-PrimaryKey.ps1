
function Get-PrimaryKey
{
    <#
    .SYNOPSIS
    Gets objects for all the columns that are part of a a table's primary key.
    #>
    param(
        [Parameter(ParameterSetName='ByTable')]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,ParameterSetName='ByTable')]
        [string]
        # The name of the table whose primary key to get.
        $TableName,

        [Parameter(Mandatory=$true,ParameterSetName='ByName')]
        [string]
        $Name
    )

    Set-StrictMode -Version Latest
    
    if( $PSCmdlet.ParameterSetName -eq 'ByTable' )
    {
        $Name = New-ConstraintName @PSBoundParameters -PrimaryKey
    }

    $query = @'
    select
       SCHEMA_NAME(t.schema_id) schema_name, t.name table_name, i.*
    from 
        sys.indexes i 
        inner join sys.tables t on i.object_id = t.object_id
    where 
        i.is_primary_key = 1 and i.name = '{0}'
'@ -f $name
    
    $key = Invoke-RivetTestQuery -Query $query 
    $key | Get-IndexColumn
}