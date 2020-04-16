function Disable-ForeignKey
{
    <#
    .SYNOPSIS
    OBSOLETE. Use `Disable-Constraint` instead.
    
    .DESCRIPTION
    OBSOLETE. Use `Disable-Constraint` instead.
    
    .EXAMPLE
    Disable-Constraint 'SourceTable' 'FK_SourceID_ReferenceTable'
    
    Demonstrates that `Disable-ForeignKey` is obsolete by showing that you should use `Disable-Constraint` instead.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the table to alter.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1)]
        [string[]]
        # The column(s) that should be part of the foreign key.
        $ColumnName,

        [Parameter(Mandatory=$true,Position=2)]
        [string]
        # The table that the foreign key references
        $References,

        [Parameter()]
        [string]
        # The schema name of the reference table.  Defaults to `dbo`.
        $ReferencesSchema = 'dbo',

        [Parameter()]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name
    )

    Set-StrictMode -Version 'Latest'


    Write-Warning ('Disable-ForeignKey''s is obsolete and will removed in a future version of Rivet. Please use `Disable-Constraint` instead.')

    if( -not $PSBoundParameters.ContainsKey('Name') )
    {
        $Name = New-Object 'Rivet.ForeignKeyConstraintName' $SchemaName, $TableName, $ReferencesSchema, $References | Select-Object -ExpandProperty 'Name'
    }

    Disable-Constraint -SchemaName $SchemaName -TableName $TableName -Name $Name
}