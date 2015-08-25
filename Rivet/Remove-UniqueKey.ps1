
function Remove-UniqueKey
{
    <#
    .SYNOPSIS
    Removes the Unique Constraint from the database

    .DESCRIPTION
    Removes the Unique Constraint from the database.

    .EXAMPLE
    Remove-UniqueKey 'Cars' -Name 'YearUK'

    Demonstrates how to remove a unique key whose name is different than the name Rivet derives for unique keys.
    #>

    [CmdletBinding(DefaultParameterSetName='ByDefaultName')]
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
        # OBSOLETE. Use the `Name` parameter to specify the name of the unique key to remove.
        $ColumnName,

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ByExplicitName')]
        [string]
        # The name of the unique key to remove.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    if( $PSCmdlet.ParameterSetName -eq 'ByDefaultName' )
    {
        Write-Warning ('Remove-UniqueKey''s ColumnName parameter is obsolete and will be removed in a future version of Rivet. Instead, use the Name parameter to remove a unique key.')
        $Name = New-Object -TypeName 'Rivet.ConstraintName' -ArgumentList $SchemaName, $TableName, $ColumnName, ([Rivet.ConstraintType]::UniqueKey) | Select-Object -ExpandProperty 'Name'
    }

    New-Object 'Rivet.Operations.RemoveUniqueKeyOperation' $SchemaName, $TableName, $Name
}
