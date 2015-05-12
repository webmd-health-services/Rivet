function Disable-ForeignKey
{
    <#
    .SYNOPSIS
    Disable a foreign key constraint on a table.
    
    .DESCRIPTION
    Disabling foreign key constraints removes validation for data in columns.
    
    .EXAMPLE
    Disable-ForeignKey 'SourceTable' 'SourceID' 'ReferenceTable'
    
    Disables the foreign key constraint on the 'SourceID' column of the 'SourceTable' referencing 'ReferenceTable'.
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
        $op = New-Object 'Rivet.Operations.DisableForeignKeyOperation' $SchemaName, $TableName, $Name
        Write-Host (' {0}.{1} -{2} ({3}) => {4}.{5}' -f $SchemaName,$TableName,$Name,$source_columns,$ReferencesSchema,$References)
    }
    else
    {
        $op = New-Object 'Rivet.Operations.DisableForeignKeyOperation' $SchemaName, $TableName, $ReferencesSchema, $references
        Write-Host (' {0}.{1} -{2} ({3}) => {4}.{5}' -f $SchemaName,$TableName,$op.Name,$source_columns,$ReferencesSchema,$References)
     
    }

    Invoke-MigrationOperation -Operation $op
}