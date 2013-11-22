
function Assert-UniqueKey
{
    <#
    .SYNOPSIS
    Tests that a unique Key exists for a particular column and table
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table
        $TableName,

        [string[]]
        # Array of Column Names
        $ColumnName,

        [Parameter()]
        [string]
        # The table's schema.  Default is `dbo`.
        $SchemaName = 'dbo',

        [Switch]
        # Index Created Should be Clustered
        $TestClustered,

        [Int]
        # Index Created Should have a Fill Factor
        $TestFillFactor,

        [Switch]
        # Test that options are passed along in the query
        $TestOption,

        [Switch]
        # Test that all unique Keys have been removed
        $TestNoUnique

    )
    
    Set-StrictMode -Version Latest

    $key_Key = Get-KeyConstraint -TableName 'AddUniqueKey' -ReturnUnique
    $id = Get-Index -TableName $TableName

    if ($TestNoUnique)
    {
        Assert-Null $key_Key ('There are unique Keys in the database')
        Assert-Null $id ('Attempt to remove a unique Key did not result in an index removal')
    }
    else
    {
        Assert-NotNull $key_Key ('There are no unique Keys in the database')
        Assert-NotNull $id ('Attempt to create a unique Key did not result in an index')

        Assert-Equal (New-ConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName -Unique) $key_Key.name
        Assert-Equal (New-ConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName -Unique) $id.name
        
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

        if ($TestFillFactor)
        {
            Assert-Equal $TestFillFactor $id.fill_factor
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
    }
}