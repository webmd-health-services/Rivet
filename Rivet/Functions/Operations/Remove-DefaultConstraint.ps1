
function Remove-DefaultConstraint
{
    <#
    .SYNOPSIS
    Removes a default constraint from a table.

    .DESCRIPTION
    The `Remove-DefaultConstraint` operation removes a default constraint from a table.

    .EXAMPLE
    Remove-DefaultConstraint 'Cars' -ColumnName 'Year' -Name 'Cars_Year_DefaultConstraint'

    Demonstrates how to remove a default constraint. In this case, the `Cars_Year_DefaultConstraint` constraint will be removed from the `Cars` table.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]
        # The name of the target table.
        [String]$TableName,

        # The schema name of the target table.  Defaults to `dbo`.
        [String]$SchemaName = 'dbo',

        [Parameter(Position=1)]
        # The column name.
        [String]$ColumnName,

        # The name of the default constraint to remove.
        [String]$Name
    )

    Set-StrictMode -Version 'Latest'

    if( -not $Name )
    {
        if( -not $ColumnName )
        {
            Write-Error -Message ('The Name parameter is mandatory. Please pass the name of the default constraint to the Name parameter.') -ErrorAction Stop
            return
        }

        Write-Warning -Message ('Not providing an explicit default constraint name is OBSOLETE. Please add the name of the default constraint you''re removing to the Name parameter.')
        $Name = New-Object -TypeName 'Rivet.ConstraintName' -ArgumentList $SchemaName, $TableName, $ColumnName, ([Rivet.ConstraintType]::Default) | Select-Object -ExpandProperty 'Name'
    }

    if( -not $ColumnName )
    {
        Write-Warning -Message ('Not providing the ColumnName parameter is obsolete. This parameter will be mandatory in a future version of Rivet. Please pass the column name whose default constraint is being removed to the ColumnName parameter.')
    }

    New-Object 'Rivet.Operations.RemoveDefaultConstraintOperation' $SchemaName, $TableName, $ColumnName, $Name
}
