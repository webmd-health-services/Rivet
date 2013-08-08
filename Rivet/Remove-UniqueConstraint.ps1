
function Remove-UniqueConstraint
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
        [string[]]
        # The column(s) on which the UniqueConstraint is based
        $ColumnName  
    )

    Set-StrictMode -Version Latest

    ## Construct UniqueConstraint name

    $UniqueConstraintname = New-ConstraintName -ColumnName $ColumnName -TableName $TableName -SchemaName $SchemaName -Unique
    $ColumnClause = $ColumnName -join ','

$query = @'
    alter table {0}.{1} drop constraint {2}

'@ -f $SchemaName, $TableName, $UniqueConstraintname

    Write-Host (' {0}.{1} -{2} ({3})' -f $SchemaName,$TableName,$UniqueConstraintname,$ColumnClause)

    #Construct Migration Object

    $migration = New-MigrationObject -Property @{ Query = $query } -ToQueryMethod { return $this.Query }

    Invoke-Migration -Migration $migration 
}
