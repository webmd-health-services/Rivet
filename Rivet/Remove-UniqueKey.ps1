
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

    .EXAMPLE
    Remove-UniqueKey 'Cars' -Name 'YearUK'

    Demonstrates how to remove a unique key whose name is different than the name Rivet derives for unique keys.
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

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ByColumnName')]
        [string[]]
        # The column(s) on which the UniqueConstraint is based
        $ColumnName,

        [Parameter(Mandatory=$true,ParameterSetName='ByExplicitName')]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    if ($PSBoundParameters.ContainsKey("Name"))
    {
        New-Object 'Rivet.Operations.RemoveUniqueKeyOperation' $SchemaName, $TableName, $Name
    }
    else 
    {
        $ColumnClause = $ColumnName -join ','
        New-Object 'Rivet.Operations.RemoveUniqueKeyOperation' $SchemaName, $TableName, $ColumnName
    }
}
