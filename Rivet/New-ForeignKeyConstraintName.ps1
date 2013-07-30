
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

    $name = 'FK_{0}_{1}_{2}_{3}' -f $SourceSchema, $SourceTable, $TargetSchema, $TargetTable

    if( $SourceSchema -eq 'dbo' -and $TargetSchema -eq 'dbo')
    {
        $name = 'FK_{0}_{1}' -f $SourceTable, $TargetTable
    }
    return $name
}

