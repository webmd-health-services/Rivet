
function Assert-Index
{
    <#
    .SYNOPSIS
    Tests that an index exists and the columns that are a part of it.
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table whose primary key to get.
        $TableName,

        [string[]]
        # Array of Column Names
        $ColumnName,

        [Parameter()]
        [string]
        # The table's schema.  Default is `dbo`.
        $SchemaName = 'dbo',

        [string]
        # The name of the index, if different than the default, computed name.
        $Name,

        [Switch]
        # Index Created Should be Clustered
        $TestClustered,

        [Switch]
        # Index Created Should be Unique
        $TestUnique,

        [Switch]
        # Test that options are passed along in the query
        $TestOption,

        [Switch]
        # Test that filter predicates are passed along in the query
        $TestFilter,

        [Parameter()]
        [bool[]]
        # Test that the specified index is descending
        $TestDescending

    )

    Set-StrictMode -Version 'Latest'

    if( -not $PSBoundParameters.ContainsKey('Name') )
    {
        $newConstraintNameParams = @{ }
        if( $TestUnique )
        {
            $newConstraintNameParams.UniqueIndex = $true
        }
        else
        {
            $newConstraintNameParams.Index = $true
        }
        $Name = New-ConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName
        $Name = $Name.ToString()
    }

    $id = Get-Index -Name $Name
    Assert-NotNull $id 

    $query = @'
    select * 
    from sys.index_columns ic join
        sys.indexes i on ic.index_id = i.index_id
    where i.name = '{0}' and i.object_id = ic.object_id
'@ -f $Name
    
    [Object[]]$id_columns = Invoke-RivetTestQuery -Query $query
    Assert-NotNull $id_columns ('Clustered or NonClustered Index Column(s) on table {0} doesn''t exist.' -f $TableName)

    ## Assert Count
    if ($id_columns -is 'Object[]')
    {
        Assert-Equal $ColumnName.Count $id_columns.Count
    }

    ## Assert Clustered / NonClustered
    if ($TestClustered)
    {
        Assert-Equal "CLUSTERED" $id.type_desc 
        Assert-Equal 1 $id.type
    }
    else
    {
        Assert-Equal "NONCLUSTERED" $id.type_desc
        Assert-Equal 2 $id.type
    }

    if ($TestUnique)
    {
        Assert-Equal $true $id.is_unique
    }
    else
    {
        Assert-Equal $false $id.is_unique
    }

    if ($TestOption)
    {
        Assert-Equal $true $id.ignore_dup_key
        Assert-Equal $false $id.allow_row_locks
    }
    else
    {
        Assert-Equal $false $id.ignore_dup_key
        Assert-Equal $true $id.allow_row_locks
    }
    
    if ($TestFilter)
    {
        Assert-Equal "([EndDate] IS NOT NULL)" $id.filter_definition
    }
    else
    {
        Assert-Null $id.filter_definition
    }

    if ($TestDescending)
    {
        for ($i = 0; $i -lt $id_columns.Length; $i++)
        { 
            Assert-Equal $TestDescending[$i] $id_columns[$i].is_descending_key
        }
    }
    else
    {
        for ($i = 0; $i -lt $id_columns.Length; $i++)
        { 
            Assert-Equal $false $id_columns[$i].is_descending_key
        }
    }
    
}