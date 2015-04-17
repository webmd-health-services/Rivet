
function Get-Index
{
    <#
    .SYNOPSIS
    Contains a row per index or heap of a tabular object, such as a table, view, or table-valued function.
    #>

    param(
        [Parameter(ParameterSetName='ByTable')]
        [string]
        # The table's schema.  Default is `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,ParameterSetName='ByTable')]
        [string]
        # The name of the table whose primary key to get.
        $TableName,

        [Parameter(ParameterSetName='ByTable')]
        [string[]]
        # Array of Column Names
        $ColumnName,

        [Parameter(Mandatory=$true,ParameterSetName='ByName')]
        $Name,

        [Switch]
        # The index is unique.
        $Unique
    )
    
    Set-StrictMode -Version Latest

    if( $PSCmdlet.ParameterSetName -eq 'ByTable' )
    {
        $Name = New-ConstraintName @PSBoundParameters -Index
        $Name = $Name.ToString()
    }

    $query = @'
    select * 
    from sys.indexes
    where name = '{0}' and index_id > 0 and type in (1,2)
'@ -f $Name
    
    $idx = Invoke-RivetTestQuery -Query $query
    $idx | Get-IndexColumn
}