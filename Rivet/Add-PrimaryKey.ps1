
function Add-PrimaryKey
{
    <#
    .SYNOPSIS
    Adds a primary key to an existing table that doesn't have a primary key.

    .DESCRIPTION
    Adds a primary key to a table.  If the table already has a primary key, make sure to remove it with `Remove-PrimaryKey`.

    .LINK
    Remove-PrimaryKey

    .EXAMPLE
    Add-PrimaryKey -TableName Cars -ColumnName Year,Make,Model

    Adds a primary key to the `Cars` table on the `Year`, `Make`, and `Model` columns.

    .EXAMPLE
    Add-PrimaryKey -TableName Cars -ColumnName Year,Make,Model -NonClustered -Option 'IGNORE_DUP_KEY = ON','DROP_EXISTING=ON'

    Demonstrates how to create a non-clustered primary key, with some index options.  
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string[]]
        # The column(s) that should be part of the primary key.
        $ColumnName,

        [Switch]
        # Create a non-clustered primary key.
        $NonClustered,

        [string[]]
        # An array of primary key options.
        $Option
    )

    Set-StrictMode -Version Latest

    $name = New-ConstraintName -TableName $TableName -SchemaName $SchemaName -ColumnName $ColumnName -PrimaryKey
    $clusteredClause = 'clustered'
    if( $NonClustered )
    {
        $clusteredClause = 'NONCLUSTERED'
    }

    if ( $Option )
    {
        $Option = $Option -join ','
        $optionClause = 'WITH ({0})' -f $Option
    }
    else
    {
        $optionClause = ''
    }
    

    $columns = $ColumnName -join ','
    $query = @'
    alter table [{0}] add constraint {1} primary key {2} ({3}) {4}
'@ -f $TableName,$name,$clusteredClause,$columns,$optionClause

    Write-Host (' +{0}.{1} primary key {2} ({3})' -f $SchemaName,$TableName,$name,$columns)
    Invoke-Query -Query $query
}
