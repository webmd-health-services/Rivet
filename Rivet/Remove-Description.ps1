
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

        [Parameter(Mandatory=$true,ParameterSetName='ForTable')]
        [Parameter(Mandatory=$true,ParameterSetName='ForColumn')]
        [Alias('Table')]
        [string]
        # The name of the table where the extended property is getting set.
        $TableName,

        [Parameter(Mandatory=$true,ParameterSetName='ForColumn')]
        [Alias('Column')]
        [string]
        # The name of the column where the extended property is getting set.
        $ColumnName,
        
        [Parameter(ParameterSetName='ForTable')]
        [Switch]
        # If you're using PowerShell v2.0, you need to specify this flag in order to set a table's description.
        $ForTable,

        [Switch]
        # Don't output any messages.
        $Quiet
    )

    $descriptionQuery = @'
        EXEC sys.sp_dropextendedproperty @name=N'MS_Description', 
                                        @level0type=N'SCHEMA', @level0name='{0}', 
                                        @level1type=N'TABLE',  @level1name='{1}'
'@ -f $SchemaName,$TableName

    $columnMsg = ''
    if( $PSCmdlet.ParameterSetName -eq 'ForColumn' )
    {
        $descriptionQuery += ",`n                                        @level2type=N'COLUMN', @level2name='{0}'" -f $ColumnName
        $columnMsg = '.{0}' -f $ColumnName
    }

    if( -not $Quiet )
    {
        Write-Host (' {0}.{1}{2} -MS_Description' -f $SchemaName,$TableName,$columnMsg)
    }
    
    #Construct Migration Object

    $migration = New-MigrationObject -Property @{ Query = $descriptionQuery } -ToQueryMethod { return $this.Query }

    Invoke-Migration -Migration $migration 
}