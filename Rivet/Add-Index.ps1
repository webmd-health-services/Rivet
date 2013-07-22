
function Add-Index
{
    <#
    .SYNOPSIS
    Creates a relational index on a specified table.

    .DESCRIPTION
    Creates a relational index on a specified table.  An index can be created before there is data on the table.  Relational indexes can be created on tables or views in another database by specifying a qualified database name.

    .LINK
    Add-Index

    .EXAMPLE
    Add-Index -TableName Cars -Column Year

    Adds a relational index in 'Year' on the table 'Cars'

    .EXAMPLE 
    Add-Index -TableName 'Cars' -Column 'Year' -Unique -Option @('IGNORE_DUP_KEY = ON','ALLOW_ROW_LOCKS = OFF')
    
    Adds an unique relational index in 'Year' on the table 'Cars' with options to ignore duplicate keys and disallow row locks.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the target table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the target table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string[]]
        # The column(s) on which the index is based
        $Column,

        [Switch]
        # Create a unique index on a table or view
        $Unique,

        [Switch]
        # Creates a clustered index, otherwise non-clustered
        $Clustered,

        [string[]]
        # An array of index options.
        $Option,

        [string]
        # The filter to use when creating a filtered index.
        $Where,

        [string]
        # The value of the `ON` clause, which controls the filegroup/partition to use for the index.
        $On,

        [string]
        # The value of the `FILESTREAM_ON` clause, which controls the placement of filestream data.
        $FileStreamOn
        
    )

    Set-StrictMode -Version Latest

    ## Read Flags, Set Strings
    $UniqueString = ""
    if ($Unique)
    {
        $UniqueString = "unique "
    }

    $clusteredString = ''
    if ($Clustered)
    {
        $ClusteredString = "clustered"
    }

    $OptionString = ""
    if ($Option)
    {
        $OptionString = $Option -join ','
        $OptionString = "WITH ({0})" -f $OptionString
    }
  
    $WhereString = ""
    if ($Where)
    {
        $WhereString = "where ({0})" -f $Where
    }

    $OnString = ""
    if ($On)
    {
        $OnString = "on {0}" -f $On
    }

    $FileStreamString = ""
    if ($FileStreamOn)
    {
        $FileStreamString = "filestream_on {0}" -f $FileStreamOn
    }

    ## Construct Index name

    $indexname = "IX_{0}"  -f $TableName

    ## Construct Comma Separated List of Columns

    $ColumnString = [string]::join(',', $Column)

$query = @'
    create {0}{1} index {2}
        on {3}.{4} ({5})
        {6}{7}{8}{9}

'@ -f $UniqueString, $ClusteredString, $indexname, $SchemaName, $TableName, $ColumnString, $OptionString, $WhereString, $OnString, $FileStreamString
    
    Write-Host (' +{0}.{1} {2} ({3})' -f $SchemaName,$TableName,$indexname,$ColumnString)

    Invoke-Query -Query $query
}
