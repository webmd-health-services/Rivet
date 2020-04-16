function Enable-ForeignKey
{
    <#
    .SYNOPSIS
    OBSOLETE. Use `Enable-Constraint` instead.
    
    .DESCRIPTION
    OBSOLETE. Use `Enable-Constraint` instead.
    
    .EXAMPLE
    Enable-Constraint 'TAbleName', 'FK_ForeignKeyName'
    
    Demonstrates that `Enable-ForeignKey` is obsolete and you should use `Enable-Constraint` instead.
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

    Write-Warning ('Enable-ForeignKey''s is obsolete and will removed in a future version of Rivet. Please use `Enable-Constraint` instead.')

    if( -not $PSBoundParameters.ContainsKey('Name') )
    {
        $Name = New-Object 'Rivet.ForeignKeyConstraintName' $SchemaName, $TableName, $ReferencesSchema, $References | Select-Object -ExpandProperty 'Name'
    }

    Enable-Constraint -SchemaName $SchemaName -TableName $TableName -Name $Name
}