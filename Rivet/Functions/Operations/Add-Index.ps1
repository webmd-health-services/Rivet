﻿
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

    .EXAMPLE
    Add-Index -TableName 'Cars' -Column 'Year' -Include 'Model'

    Adds a relational index in 'Year' on the table 'Cars' and includes the column 'Model'

    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the target table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the target table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1)]
        [string[]]
        # The column(s) on which the index is based
        $ColumnName,

        [Parameter()]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name,

        [string[]]
        # Column names to include in the index.
        $Include,

        [Parameter(ParameterSetName='Descending')]
        [bool[]]
        # Optional array of booleans to specify descending switch per column.  Length must match $ColumnName
        $Descending,

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

    ## Threshold check for $Descending, and whether the length matches $ColumnName

    if ($PSBoundParameters.containskey("Descending") -and $PSCmdlet.ParameterSetName -eq "Descending")
    {
        if ($ColumnName.length -ne $Descending.length)
        {
            throw "Number of elements of Descending must match number of elements of ColumnName, if it is specified."
            return
        }
    }

    ## Construct Comma Separated List of Columns

    $ColumnClause = $ColumnName -join ','

    if ($PSBoundParameters.containskey("Descending"))
    {
        if ($PSBoundParameters.containskey("Name"))
        {
            New-Object 'Rivet.Operations.AddIndexOperation' $SchemaName, $TableName, $ColumnName, $Name, $Descending, $Unique, $Clustered, $Option, $Where, $On, $FileStreamOn, $Include
        }
        else 
        {
            New-Object 'Rivet.Operations.AddIndexOperation' $SchemaName, $TableName, $ColumnName, $Descending, $Unique, $Clustered, $Option, $Where, $On, $FileStreamOn, $Include
        }
    }
    else
    {
        if ($PSBoundParameters.containskey("Name"))
        {
            New-Object 'Rivet.Operations.AddIndexOperation' $SchemaName, $TableName, $ColumnName, $Name, $Unique, $Clustered, $Option, $Where, $On, $FileStreamOn, $Include
        }
        else 
        {
            New-Object 'Rivet.Operations.AddIndexOperation' $SchemaName, $TableName, $ColumnName, $Unique, $Clustered, $Option, $Where, $On, $FileStreamOn, $Include
        }
    }
}