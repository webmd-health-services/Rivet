
function New-ForeignKeyConstraintName
{
    <#
    .SYNOPSIS
    Creates a default foreign key constraint name.  FK_(SourceSchema)_(SourceTable)_(TargetSchema)_(TargetTable)
    #>
    [CmdletBinding()]
    param(

        [Parameter()]
        [string]
        # The source table's schema.  Default is `dbo`.
        $SourceSchema = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The SourceTable Name
        $SourceTable,

        [Parameter()]
        [string]
        # The target table's schema.  Default is `dbo`.
        $TargetSchema = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The TargetTable Name
        $TargetTable

        
    )

    $op = New-Object 'Rivet.ForeignKeyConstraintName' $SourceSchema, $SourceTable, $TargetSchema, $TargetTable
    return $op.Name
}

