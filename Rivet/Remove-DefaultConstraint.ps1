
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
        [string]
        # The column(s) on which the DefaultConstraint is based
        $ColumnName

    )

    Set-StrictMode -Version Latest

    ## Construct DefaultConstraint name

    $DefaultConstraintname = New-ConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName -Default

    Write-Host (' {0}.{1} -{2}' -f $SchemaName,$TableName,$DefaultConstraintname)

    $op = New-Object 'Rivet.Operations.RemoveDefaultConstraintOperation' $SchemaName, $TableName, $ColumnName
    Invoke-MigrationOperation -Operation $op
}
