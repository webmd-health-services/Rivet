
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

    .EXAMPLE
    Remove-Index 'Cars' -Name 'YearIX'

    Demonstrates how to drop an index with a different name than the name Rivet derives for index.
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

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ByDefaultName')]
        [string[]]
        # The column(s) on which the index is based
        $ColumnName,

        [Parameter(ParameterSetName='ByDefaultName')]
        [Switch]
        # Removes a unique index.
        $Unique,

        [Parameter(Mandatory=$true,ParameterSetName='ByExplicitName')]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    if( $PSBoundParameters.ContainsKey("Name") )
    {
        $op = New-Object 'Rivet.Operations.RemoveIndexOperation' $SchemaName, $TableName, $Name
    }
    else 
    {
        $type = [Rivet.ConstraintType]::Index
        if( $Unique )
        {
            $type = [Rivet.ConstraintType]::UniqueIndex
        }
        $op = New-Object 'Rivet.Operations.RemoveIndexOperation' $SchemaName, $TableName, $ColumnName, $type
    }

    Write-Host (' {0}.{1} -{2}' -f $SchemaName,$TableName,$op.Name) 
    Invoke-MigrationOperation -Operation $op
}
