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
        [Parameter(Mandatory,Position=0)]
        # The name of the table to alter.
        [String]$TableName,

        # The schema name of the table.  Defaults to `dbo`.
        [String]$SchemaName = 'dbo',

        [Parameter(Mandatory,Position=1)]
        # The column(s) that should be part of the foreign key.
        [String[]]$ColumnName,

        [Parameter(Mandatory,Position=2)]
        # The table that the foreign key references
        [String]$References,

        [Parameter()]
        # The schema name of the reference table.  Defaults to `dbo`.
        [String]$ReferencesSchema = 'dbo',

        # The name for the <object type>. If not given, a sensible name will be created.
        [String]$Name
    )

    Set-StrictMode -Version 'Latest'

    Write-Warning ('The "Disable-ForeignKey" operation is obsolete and will removed in a future version of Rivet. Please use "Disable-Constraint" instead.')

    if( -not $PSBoundParameters.ContainsKey('Name') )
    {
        $Name = New-ConstraintName -ForeignKey `
                                   -SchemaName $SchemaName `
                                   -TableName $TableName `
                                   -ReferencesSchemaName $ReferencesSchema `
                                   -ReferencesTableName $References 
    }

    Disable-Constraint -SchemaName $SchemaName -TableName $TableName -Name $Name
}