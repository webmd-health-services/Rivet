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

        # The schema name of the reference table.  Defaults to `dbo`.
        [String]$ReferencesSchema = 'dbo',

        # The name for the <object type>. If not given, a sensible name will be created.
        [String]$Name
    )

    Set-StrictMode -Version 'Latest'

    Write-Warning ('The "Enable-ForeignKey" operation is obsolete and will removed in a future version of Rivet. Please use "Enable-Constraint" instead.')

    if( -not $PSBoundParameters.ContainsKey('Name') )
    {
        $Name = New-ConstraintName -ForeignKey `
                                   -SchemaName $SchemaName `
                                   -TableName $TableName `
                                   -ReferencesSchemaName $ReferencesSchema `
                                   -ReferencesTableName $References 
    }

    Enable-Constraint -SchemaName $SchemaName -TableName $TableName -Name $Name
}