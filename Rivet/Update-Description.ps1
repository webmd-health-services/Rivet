
function Update-Description
{
    <#
    .SYNOPSIS
    Updates the `MS_Description` extended property of a table or column.

    .DESCRIPTION
    The `sys.sp_updateextendedproperty` stored procedure is used to update a table/column's description (i.e. the `MS_Description` extended property), but the syntax is weird.  This function hides that weirdness from you.  You're welcome.

    .EXAMPLE
    Update-Description -Description 'Whoseit's whatsits table.' -TableName WhoseitsWhatsits 

    Updates the description (i.e. the `MS_Description` extended property) on the `WhoseitsWhatsits` table.

    .EXAMPLE
    Update-Description  -Description 'Is it a snarfblat?' -TableName WhoseitsWhatsits -ColumnName IsSnarfblat

    Updates the description (i.e. the `MS_Description` extended property) on the `WhoseitsWhatsits` table's `IsSnarfblat` column.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The value for the MS_Description extended property.
        $Description,

        [Alias('Schema')]
        [string]
        # The schema.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,ParameterSetName='ForTable')]
        [Parameter(Mandatory=$true,ParameterSetName='ForColumn')]
        [Alias('Table')]
        [string]
        # The name of the table where the extended property is getting updated.
        $TableName,

        [Parameter(Mandatory=$true,ParameterSetName='ForColumn')]
        [Alias('Column')]
        [string]
        # The name of the column where the extended property is getting updated.
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
        EXEC sys.sp_updateextendedproperty @name=N'MS_Description', 
                                           @value='{0}',
                                           @level0type=N'SCHEMA', @level0name='{1}', 
                                           @level1type=N'TABLE',  @level1name='{2}'
'@ -f $Description.Replace("'", "''"),$SchemaName,$TableName

    $columnMsg = ''
    if( $PSCmdlet.ParameterSetName -eq 'ForColumn' )
    {
        $descriptionQuery += ",`n                                        @level2type=N'COLUMN', @level2name='{0}'" -f $ColumnName
        $columnMsg = '.{0}' -f $ColumnName
    }

    if( -not $Quiet )
    {
        Write-Host (' {0}.{1}{2} =MS_Description: {3}' -f $SchemaName,$TableName,$columnMsg,$Description)
    }
    
    $op = New-Object 'Rivet.Operations.RawQueryOperation' $descriptionQuery
    Invoke-MigrationOperation -Operation $op 
}