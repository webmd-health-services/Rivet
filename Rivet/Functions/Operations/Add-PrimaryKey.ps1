
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
        # The schema name of the table.  Defaults to `dbo`.
        [String]$SchemaName = 'dbo',

        # The name for the primary key constraint.
        [String]$Name,

        [Parameter(Mandatory,Position=0)]
        # The name of the table.
        [String]$TableName,

        [Parameter(Mandatory,Position=1)]
        # The column(s) that should be part of the primary key.
        [String[]]$ColumnName,

        # Create a non-clustered primary key.
        [switch]$NonClustered,

        # An array of primary key options.
        [String[]]$Option
    )

    Set-StrictMode -Version 'Latest'

    if( -not $Name )
    {
        $Name = New-ConstraintName -PrimaryKey -SchemaName $SchemaName -TableName $TableName -ColumnName $ColumnName
        Write-Warning ("Primary key constraint names will be required in a future version of Rivet. Please add a ""Name"" parameter (with a value of ""$($Name)"") to the Add-PrimaryKey operation for the [$($SchemaName)].[$($TableName)].[$($ColumnName)] column.")
    }

    [Rivet.Operations.AddPrimaryKeyOperation]::New($SchemaName, $TableName, $Name, $ColumnName, $NonClustered, $Option)
}
