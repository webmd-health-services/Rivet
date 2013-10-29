
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
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1)]
        [string[]]
        # The column(s) that should be part of the primary key.
        $ColumnName,

        [Switch]
        # Create a non-clustered primary key.
        $NonClustered,

        [string[]]
        # An array of primary key options.
        $Option,

        [Parameter()]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name
    )

    Set-StrictMode -Version Latest

    $columns = $ColumnName -join ','

    if ($PSBoundParameters.containskey("Name"))
    {
        $op = New-Object 'Rivet.Operations.AddPrimaryKeyOperation' $SchemaName, $TableName, $ColumnName, $Name, $NonClustered, $Option
    }
    else 
    {
        $op = New-Object 'Rivet.Operations.AddPrimaryKeyOperation' $SchemaName, $TableName, $ColumnName, $NonClustered, $Option
    }

    Write-Host (' {0}.{1} +{2} ({3})' -f $SchemaName,$TableName,$op.ConstraintName.Name,$columns)
    Invoke-MigrationOperation -Operation $op
}
