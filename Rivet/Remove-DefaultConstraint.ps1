
function Remove-DefaultConstraint
{
    <#
    .SYNOPSIS
    Removes the Default Constraint from the database

    .DESCRIPTION
    Removes the Default Constraint from the database.

    .LINK
    Remove-DefaultConstraint

    .EXAMPLE
    Remove-DefaultConstraint -TableName Cars -Column Year

    Drops a Default Constraint of column 'Year' in the table 'Cars'

    .EXAMPLE
    Remove-DefaultConstraint 'Cars' -Name 'Cars_Year_DefaultConstraint'

    Demonstrates how to remove a default constraint with a name different than the derived name Rivet creates for default constraints.
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
        [string]
        # The column(s) on which the DefaultConstraint is based
        $ColumnName,

        [Parameter(Mandatory=$true,ParameterSetName='ByCustomName')]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name

    )

    Set-StrictMode -Version 'Latest'

    if( $PSBoundParameters.ContainsKey("Name") )
    {
        $op = New-Object 'Rivet.Operations.RemoveDefaultConstraintOperation' $SchemaName, $TableName, $null, $Name
    }
    else 
    {
        $op = New-Object 'Rivet.Operations.RemoveDefaultConstraintOperation' $SchemaName, $TableName, $ColumnName
    }

    Write-Verbose (' {0}.{1} -{2}' -f $SchemaName,$TableName,$op.Name)
    return $op
}
