
function Assert-Index
{
    <#
    .SYNOPSIS
    Tests that an index exists and the columns that are a part of it.
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

        [string[]]
        # Array of Column Names
        $ColumnName,

        [Parameter(Mandatory=$true,ParameterSetName='ByName')]
        [string]
        # The name of the index, if different than the default, computed name.
        $Name,

        [Switch]
        # Make sure it's a unique index.
        $Unique,

        [Switch]
        # Index Created Should be Clustered
        $Clustered,

        [Switch]
        # Assert that the ignore_dup_key option is ON
        $IgnoreDupKey,

        [Switch]
        # Assert the allow_row_locks options is ON
        $DenyRowLocks,

        [Switch]
        # Test that options are passed along in the query
        $TestOption,

        [string]
        # Assert the index's filter predicates
        $Filter,

        [Parameter()]
        [bool[]]
        # Test that the specified index is descending
        $Descending
    )

    Set-StrictMode -Version 'Latest'

    if( $PSCmdlet.ParameterSetName -eq 'ByName' )
    {
        $id = Get-Index -Name $Name -Unique:$Unique
        Assert-NotNull $id ('Index {0} not found.' -f $Name)
    }
    else
    {
        $id = Get-Index -SchemaName $SchemaName -TableName $TableName -ColumnName $ColumnName -Unique:$Unique
        Assert-NotNull $id ('Index {0}.{1}.{2} not found.' -f $SchemaName,$TableName,($ColumnName -join ','))
    }

    ## Assert Clustered / NonClustered
    if( $Clustered )
    {
        Assert-Equal "CLUSTERED" $id.type_desc 
        Assert-Equal 1 $id.type
    }
    else
    {
        Assert-Equal "NONCLUSTERED" $id.type_desc
        Assert-Equal 2 $id.type
    }

    Assert-Equal $Unique $id.is_unique
    Assert-Equal $IgnoreDupKey $id.ignore_dup_key
    Assert-Equal (-not $DenyRowLocks) $id.allow_row_locks

    if( $PSBoundParameters.ContainsKey( 'Filter' ) )
    {
        Assert-Equal $Filter $id.filter_definition
    }
    else
    {
        Assert-Null $id.filter_definition
    }

    $columns = $id.Columns

    Assert-Equal $ColumnName.Count $columns.Count
    for( $idx = 0; $idx -lt $ColumnName.Count; ++$idx )
    {
        Assert-Equal $ColumnName[$idx] $columns[$idx].column_name
    }

    if( $PSBoundParameters.ContainsKey('Descending') )
    {
        for ($i = 0; $i -lt $columns.Length; $i++)
        { 
            Assert-Equal $Descending[$i] $columns[$i].is_descending_key
        }
    }
    else
    {
        for ($i = 0; $i -lt $columns.Length; $i++)
        { 
            Assert-Equal $false $columns[$i].is_descending_key
        }
    }
    
}