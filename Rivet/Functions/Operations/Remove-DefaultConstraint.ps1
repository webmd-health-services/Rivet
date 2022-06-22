
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
    }

    if( -not $ColumnName )
    {
        $nameMsg = ''
        if( $Name )
        {
            $nameMsg = "'s $($Name) constraint"
        }
        $msg = ('The ColumnName parameter will be required in a future version of Rivet. Add a "ColumnName" ' +
                "parameter to the Remove-DefaulConstraint operation for the [$($SchemaName)].[$($TableName)] " +
                "table$($nameMsg).")
        Write-Warning -Message $msg
    }

    [Rivet.Operations.RemoveDefaultConstraintOperation]::New($SchemaName, $TableName, $ColumnName, $Name)
}
