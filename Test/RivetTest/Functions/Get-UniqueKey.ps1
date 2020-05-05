
function Get-UniqueKey
{
    <#
    .SYNOPSIS
    Gets a unique key.
    #>
    [CmdletBinding(DefaultParameterSetName='ByDefaultName')]
    param(
        [Parameter(ParameterSetName='ByDefaultName')]
        [String]$SchemaName = 'dbo',

        [Parameter(Mandatory,ParameterSetName='ByDefaultName')]
        # The name of the table whose primary key to get.
        [String]$TableName,

        [Parameter(ParameterSetName='ByDefaultName')]
        # Columns that are part of the key.
        [String[]]$ColumnName,

        [Parameter(Mandatory,ParameterSetName='ByCustomName')]
        [String]$Name
    )
    
    Set-StrictMode -Version Latest

    if( -not $Name )
    {
        $Name = New-RTConstraintName @PSBoundParameters -UniqueKey
    }

    $query = @'
    select
       SCHEMA_NAME(t.schema_id) schema_name, t.name table_name, i.*
    from 
        sys.indexes i 
        inner join sys.tables t on i.object_id = t.object_id
    where 
        i.is_unique_constraint = 1 and i.name = '{0}'
'@ -f $name
    
    $key = Invoke-RivetTestQuery -Query $query 
    $key | Get-IndexColumn

}
