
function Remove-DefaultConstraint
{
    <#
    .SYNOPSIS
    Removes a default constraint from a table.

    .DESCRIPTION
    The `Remove-DefaultConstraint` operation removes a default constraint from a table.

    .EXAMPLE
    Remove-DefaultConstraint 'Cars' -Name 'Cars_Year_DefaultConstraint'

    Demonstrates how to remove a default constraint. IN this case, the `Cars_Year_DefaultConstraint` constraint will be removed from the `Cars` table.
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
        [string]
        # OBSOLETE. Use the `Name` parameter to remove a default constraint.
        $ColumnName,

        [Parameter(Mandatory=$true,ParameterSetName='ByCustomName')]
        [string]
        # The name of the default constraint to remove.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    if( $PSCmdlet.ParameterSetName -eq 'ByDefaultName' )
    {
        Write-Warning ('Remove-DefaultConstraint''s ColumnName parameter is obsolete and will be removed in a future version of Rivet. Instead, use the Name parameter to remove a default constraint.')
        $Name = New-Object -TypeName 'Rivet.ConstraintName' -ArgumentList $SchemaName, $TableName, $ColumnName, ([Rivet.ConstraintType]::Default) | Select-Object -ExpandProperty 'Name'
    }

    New-Object 'Rivet.Operations.RemoveDefaultConstraintOperation' $SchemaName, $TableName, $Name
}
