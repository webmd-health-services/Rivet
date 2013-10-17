
function Add-DefaultConstraint
{
    <#
    .SYNOPSIS
    Creates a Default constraint to an existing column

    .DESCRIPTION
    Creates a Default constraint to an existing column 
    The DEFAULT constraint is used to insert a default value into a column.  The default value will be added to all new records, if no other value is specified.
    
    .LINK
    Add-DefaultConstraint

    .EXAMPLE
    Add-DefaultConstraint -TableName Cars -ColumnName Year

    Adds an Default constraint on column 'Year' in the table 'Cars'

    .EXAMPLE 
    Add-DefaultConstraint -TableName 'Cars' -ColumnName 'Year' ##TODO###

    Adds an Default constraint on column 'Year' in the table 'Cars' with specified options

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
        [string]
        # The column on which to add the default constraint
        $ColumnName,

        [Parameter(Mandatory=$true,Position=2)]
        [string]
        #The default expression
        $Expression,

        [Parameter()]
        [switch]
        #WithValues
        $WithValues 
    )

    Set-StrictMode -Version Latest

    $op = New-Object 'Rivet.Operations.AddDefaultConstraintOperation' $SchemaName, $TableName, $Expression, $ColumnName, $WithValues
    Write-Host (' {0}.{1} +{2} {3} {4}' -f $SchemaName, $TableName, $op.ConstraintName.Name, $ColumnName, $Expression)
    Invoke-MigrationOperation -Operation $op
}
