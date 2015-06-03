
function Assert-PrimaryKey
{
    <#
    .SYNOPSIS
    Tests that a primary key exists and the columns that are a part of it.
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
        # The name of the primary key.
        $Name,

        [Parameter(Mandatory=$true)]
        [string[]]
        # The column(s) that are part of the primary key.
        $ColumnName,

        [Switch]
        # Create a non-clustered primary key.
        $NonClustered,

        [int]
        $FillFactor,

        [Switch]
        $IgnoreDupKey
    )
    
    Set-StrictMode -Version Latest

    if( $PSCmdlet.ParameterSetName -eq 'ByName' )
    {
        $getPrimaryKeyParams = @{ Name = $Name }
    }
    else
    {
        $getPrimaryKeyParams = @{ SchemaName = $SchemaName ; TableName = $TableName }
    }

    $pk = Get-PrimaryKey @getPrimaryKeyParams
    Assert-NotNull $pk ('Primary Key on table {0}.{1} doesn''t exist.' -f $SchemaName,$TableName)

    if ($NonClustered)
    {
        Assert-Equal "NONCLUSTERED" $pk[0].type_desc 
    }

    Assert-Equal $IgnoreDupKey $pk.ignore_dup_key

    if( $PSBoundParameters.ContainsKey('FillFactor') )
    {
        Assert-Equal $FillFactor $pk.fill_factor
    }

    Assert-Equal $ColumnName.Count $pk.Columns.Count
    for( $idx = 0; $idx -lt $ColumnName.Count; ++$idx )
    {
        $ordinal = $idx + 1
        Assert-Equal $ColumnName[$idx] $pk.Columns[$idx].column_name ('{0}.{1}: Unexpected column at ordinal {2}' -f $SchemaName,$TableName,$ordinal)
        Assert-Equal $ordinal $pk.Columns[$idx].key_ordinal
    }
}
