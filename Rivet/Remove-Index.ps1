
function Remove-Index
{
    <#
    .SYNOPSIS
    Removes one relational index from the database

    .DESCRIPTION
    Removes one relational index from the database.

    .LINK
    Remove-Index

    .EXAMPLE
    Remove-Index -TableName Cars -Column Year

    Drops a relational index of column 'Year' on the table 'Cars'

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
        $Name
    )

    Set-StrictMode -Version 'Latest'

    if ($PSBoundParameters.containskey("Name"))
    {
        $op = New-Object 'Rivet.Operations.RemoveIndexOperation' $SchemaName, $TableName, $Name
        Write-Host (' {0}.{1} -{2}' -f $SchemaName,$TableName,$Name) 
    }
    else 
    {
        $op = New-Object 'Rivet.Operations.RemoveIndexOperation' $SchemaName, $TableName, $ColumnName
        Write-Host (' {0}.{1} -{2}' -f $SchemaName,$TableName,$op.Name) 
    }

    Invoke-MigrationOperation -Operation $op
}
