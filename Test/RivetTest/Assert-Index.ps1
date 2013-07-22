
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

        [Switch]
        # Test that the specified index is removed
        $TestNoIndex

    )

    $id = @(Get-Index -TableName $TableName)
    $id_columns = @(Get-IndexColumns -TableName $TableName)
    
    if ($TestNoIndex)
    {
        Assert-Null $id ('Clustered or NonClustered Index on table {0} does exist.' -f $TableName)
        Assert-Null $id_columns ('Clustered or NonClustered Index Column(s) on table {0} does exist.' -f $TableName)
    }
    else
    {
        Assert-NotNull $id ('Clustered or NonClustered Index on table {0} doesn''t exist.' -f $TableName)
        Assert-NotNull $id_columns ('Clustered or NonClustered Index Column(s) on table {0} doesn''t exist.' -f $TableName)

        ## Assert Index Name
        Assert-Equal (Join-String "IX_",$TableName) $id.name

        ## Assert Count
        Assert-Equal $ColumnName.Count $id_columns.Count

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
            Assert-Equal '' $id.filter_definition
        }
    }
    
}