
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

        [Parameter(Mandatory=$true)]
        [Alias('Table')]
        [string]
        # The name of the table where the extended property is getting updated.
        $TableName,

        [Parameter(ParameterSetName='ForColumn')]
        [Alias('Column')]
        [string]
        # The name of the column where the extended property is getting updated.
        $ColumnName,

        [Switch]
        # Don't output any messages.
        $Quiet
    )

    $optionalArgs = @{ }
    if( $ColumnName )
    {
        $optionalArgs.ColumnName = $ColumnName
    }

    Update-ExtendedProperty -Name 'MS_Description' `
                            -Value $Description `
                            -SchemaName $SchemaName `
                            -TableName $TableName `
                            -Quiet:$Quiet `
                            @optionalArgs

}