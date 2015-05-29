function Enable-ForeignKey
{
    <#
    .SYNOPSIS
    Enable a previously disabled foreign key constraint on a table.
    
    .DESCRIPTION
    Re-enabling foreign key constraints reapplies validation for data in columns.
    
    .EXAMPLE
    Enable-ForeignKey 'SourceTable' 'SourceID' 'ReferenceTable'
    
    Enables the disabled foreign key constraint on the 'SourceID' column of the 'SourceTable' referencing 'ReferenceTable'.
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

    $source_columns = $ColumnName -join ','

    if ($PSBoundParameters.containskey("Name"))
    {
        Write-Verbose (' {0}.{1} +{2} ({3}) => {4}.{5}' -f $SchemaName,$TableName,$Name,$source_columns,$ReferencesSchema,$References)
        New-Object 'Rivet.Operations.EnableForeignKeyOperation' $SchemaName, $TableName, $Name
    }
    else
    {
        $op = New-Object 'Rivet.Operations.EnableForeignKeyOperation' $SchemaName, $TableName, $ReferencesSchema, $references
        Write-Verbose (' {0}.{1} +{2} ({3}) => {4}.{5}' -f $SchemaName,$TableName,$op.Name,$source_columns,$ReferencesSchema,$References)
        $op
    }
}