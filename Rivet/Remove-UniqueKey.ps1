
function Remove-UniqueKey
{
    <#
    .SYNOPSIS
    Removes the Unique Constraint from the database

    .DESCRIPTION
    Removes the Unique Constraint from the database.

    .LINK
    Remove-UniqueConstraint

    .EXAMPLE
    Remove-UniqueConstraint -TableName Cars -Column Year

    Drops a Unique Constraint of column 'Year' in the table 'Cars'

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
        # The column(s) on which the UniqueConstraint is based
        $ColumnName,

        [Parameter()]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    $ColumnClause = $ColumnName -join ','

    if ($PSBoundParameters.containskey("Name"))
    {
        $op = New-Object 'Rivet.Operations.RemoveUniqueKeyOperation' $SchemaName, $TableName, $Name
    }
    else 
    {
        $op = New-Object 'Rivet.Operations.RemoveUniqueKeyOperation' $SchemaName, $TableName, $ColumnName
    }
    
    Write-Host (' {0}.{1} -{2} ({3})' -f $SchemaName,$TableName,$op.Name,$ColumnClause)
    Invoke-MigrationOperation -Operation $op
}
