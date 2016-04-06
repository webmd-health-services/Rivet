
function Remove-Description
{
    <#
    .SYNOPSIS
    Removes the `MS_Description` extended property for a table or column.

    .DESCRIPTION
    The `sys.sp_dropextendedproperty` stored procedure is used to remove a table/column's description (i.e. the `MS_Description` extended property), but the syntax is weird.  This function hides that weirdness from you.  You're welcome.

    .EXAMPLE
    Remove-Description -TableName WhoseitsWhatsits 

    Removes the description (i.e. the `MS_Description` extended property) for the `WhoseitsWhatsits` table.

    .EXAMPLE
    Remove-Description -TableName WhoseitsWhatsits -ColumnName IsSnarfblat

    Removes the description (i.e. the `MS_Description` extended property) for the `WhoseitsWhatsits` table's `IsSnarfblat` column.
    #>
    [CmdletBinding()]
    param(
        [Alias('Schema')]
        [string]
        # The schema.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [Alias('Table')]
        [string]
        # The name of the table where the extended property is getting set.
        $TableName,

        [Parameter(ParameterSetName='ForColumn')]
        [Alias('Column')]
        [string]
        # The name of the column where the extended property is getting set.
        $ColumnName
    )

    Set-StrictMode -Version 'Latest'

    $optionalArgs = @{ }
    if( $ColumnName )
    {
        $optionalArgs.ColumnName = $ColumnName
    }
    
    Remove-ExtendedProperty -Name 'MS_Description' `
                            -SchemaName $SchemaName `
                            -TableName $TableName `
                            @optionalArgs
}