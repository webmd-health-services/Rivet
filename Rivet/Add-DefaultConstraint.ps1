
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
        #The default expression
        $Expression,

        [Parameter(Mandatory=$true)]
        [string]
        # The column on which to add the default constraint
        $ColumnName,

        [Parameter()]
        [switch]
        #WithValues
        $WithValues 
    )

    Set-StrictMode -Version Latest

    $DefaultConstraintName = New-ConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName -Default

    $WithValuesClause = ''
    if ($WithValues)
    {
        $WithValuesClause = 'with values'
    }

$query = @'
    alter table {0}.{1}
    add constraint {2} default {3} for {4} {5}
'@ -f $SchemaName, $TableName, $DefaultConstraintName, $Expression, $ColumnName, $WithValuesClause
    
    Write-Host (' {0}.{1} +{2} {3} {4}' -f $SchemaName, $TableName, $DefaultConstraintName, $ColumnName, $Expression)

    $migration = New-MigrationObject -Property @{ Query = $query } -ToQueryMethod { return $this.Query }

    Invoke-Migration -Migration $migration 
}
